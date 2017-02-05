require 'milliseconds'

class CurrenciesController < ApplicationController
  before_action :authenticate_user!
  # GET /currencies
  def index
    method_name = "[#{self.class}::#{__method__}]"
    begin
      timer = Milliseconds.new

      @limit = per_page = params[:per_page].to_i < 1 ? 10 : params[:per_page].to_i
      @offset = params[:page].to_i < 1 ? 0 : (params[:page].to_i - 1) * @limit
      @sort = params[:sort] || 'name'
      
      if params[:search]
        conditions_stmt = generate_search(params)
      end

      @currencies = Currency.where(conditions_stmt).limit(@limit).offset(@offset).order(@sort)
      num_elements = Currency.where(conditions_stmt).size
      timer.stop

      @elapsed = timer.ms/1000.0

      hsh = {
        :offset   => params[:page].to_i,
        :total    => num_elements,
        :order    => params[:sort],
        :query    => conditions_stmt,
        :rows     => @currencies.as_json,
        :elapsed  => @elapsed
      }

      data = JSON.fast_generate hsh

      respond_to do |format|
        format.json { render :json => data }
      end
    rescue StandardError => e
      Rails.logger.error {"Exception in #{method_name}: #{e.message}"}
      puts "Exception in #{method_name}: #{e.message}"
      render :json => { :errors => e.message }, :status => 400
    end
  end

  # GET /currencies/1
  def show
    begin
      if params.key? 'collected'
        @currency = Currency.find(params[:id]).collected?
      else
        @currency = Currency.find(params[:id])
      end
    rescue ActiveRecord::RecordNotFound
      Rails.logger.warn {'Currency record not found'}
    end
    respond_to do |format|
      format.json { render :json => @currency }
    end
  end

  # Currencies collected over time
  def collected_over_time
    collected = Currency.select('strftime("%Y","currencies".`updated_at`) AS `year`, count("currencies".code) as total_collected').joins('JOIN "countries" c ON c.code = "currencies".country_id AND c.visited = "t"').group('year')
    respond_to do |format|
        format.json { render :json => collected.as_json }
    end
  end

  # Currencies collected vs not_collected
  def collected_vs_notcollected
    @collected = Currency.collected.size
    @not_collected = Currency.not_collected.size
    response = {'collected': @collected, 'not_collected': @not_collected}
    respond_to do |format|
        format.json { render :json => response.as_json }
    end
  end

  # Create where clause for search query
  def generate_search (options)
    conditions_stmt = ''

    if options[:id].to_s.strip != '' then
      options[:id] = CGI::unescape(options[:id])
      conditions_stmt += ' AND ' unless conditions_stmt == ''
      conditions_stmt += 'code = "' + options[:id].to_s.strip + '"'
    end
    
    if options[:name].to_s.strip != '' then
      options[:name] = CGI::unescape(options[:name])
      conditions_stmt += ' AND ' unless conditions_stmt == ''
      if options[:name] =~ /\*|\%/
        options[:name] = options[:name].gsub('*', '%')
        conditions_stmt += 'name LIKE "' + options[:name].to_s.strip + '"'
      else
        if options[:name] =~ /!/
          conditions_stmt += 'name != "' + options[:name].gsub('!', '').to_s.strip + '"'
        else
          conditions_stmt += 'name = "' + options[:name].to_s.strip + '"'
        end
      end
    end

    if options[:weight].to_s.strip != '' then
      options[:weight] = CGI::unescape(options[:weight])
      conditions_stmt += ' AND ' unless conditions_stmt == ''
      if options[:weight].starts_with?('>')
        options[:weight] = options[:weight].gsub('>', '')
        conditions_stmt += 'weight > "' + options[:weight].to_s.strip + '"'
      elsif options[:weight].starts_with?('<')
        options[:weight] = options[:weight].gsub('<', '')
        conditions_stmt += 'weight < "' + options[:weight].to_s.strip + '"'
      else
        conditions_stmt += 'weight = "' + options[:weight].to_s.strip + '"'
      end
    end

    if options[:collector_value].to_s.strip != '' then
      options[:collector_value] = CGI::unescape(options[:collector_value])
      conditions_stmt += ' AND ' unless conditions_stmt == ''
      if options[:collector_value].starts_with?('>')
        options[:collector_value] = options[:collector_value].gsub('>', '')
        conditions_stmt += 'collector_value > "' + options[:collector_value].to_s.strip + '"'
      elsif options[:collector_value].starts_with?('<')
        options[:collector_value] = options[:collector_value].gsub('<', '')
        conditions_stmt += 'collector_value < "' + options[:collector_value].to_s.strip + '"'
      else
        conditions_stmt += 'collector_value = "' + options[:collector_value].to_s.strip + '"'
      end
    end
    
    Rails.logger.debug {"Search conditions: #{conditions_stmt}"}
    conditions_stmt
  end

end