require 'milliseconds'

class CountriesController < ApplicationController
  before_action :authenticate_user!
  
  # GET /countries
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

      @countries = Country.where(conditions_stmt).limit(@limit).offset(@offset).order(@sort)
      num_elements = Country.where(conditions_stmt).size
      timer.stop

      @elapsed = timer.ms/1000.0

      hsh = {
        :offset   => params[:page].to_i,
        :total    => num_elements,
        :order    => params[:sort],
        :query    => conditions_stmt,
        :rows     => @countries.as_json,
        :elapsed  => @elapsed
      }

      data = JSON.fast_generate hsh

      respond_to do |format|
        format.json { render :json => data }
      end
    rescue StandardError => e
      Rails.logger.error {"Exception in #{method_name}: #{e.message}"}
      render :json => { :errors => e.message }, :status => 500
    end
  end

  # GET /countries/1
  def show
    begin
      if params.key? 'visited'
        @country = Country.find(params[:id]).visited?
      else
        @country = Country.find(params[:id])
      end
    rescue ActiveRecord::RecordNotFound
      Rails.logger.warn {'Country record not found'}
    end

    respond_to do |format|
      format.json { render :json => @country }
    end
  end

  # GET /countries/1/edit
  def edit
    @country = Country.find(params[:id])
  end

  # POST /countries
  def create
    @country = Country.new(params[:country].permit(:visited,:name,:code))
    
    respond_to do |format|
      if @country.save
        format.json { render :json => @country }
      else
        format.json { render :json => @country.errors, :status => :unprocessable_entity}
      end
    end
  end

  # PUT /countries/1
  def update
    @country = Country.find(params[:id])

    respond_to do |format|
      if @country.update_attributes(params[:country].permit(:visited,:name,:code))
        format.json { render :status => :ok }
      else
        format.json { render :json => @country.errors, :status => :unprocessable_entity}
      end
    end
  end

  def visited_over_time
    visits = Country.select('strftime("%Y",`updated_at`) AS `year`, count(code) as total_visits').where('visited = "t"').group('year')
    respond_to do |format|
        format.json { render :json => visits.as_json }
    end
  end

  def visited_vs_notvisited
    @visited = Country.visited.size
    @not_visited = Country.not_visited.size
    response = {'visited': @visited, 'not_visited': @not_visited}
    respond_to do |format|
        format.json { render :json => response.as_json }
    end
  end

  # Params: weight - Return list of countries with maximum collector values
  def countries_with_max_currency_value
    given_weight = params[:weight].to_i
    currency = Currency.all.to_a;
    max_values = Array.new(given_weight + 1, 0)
    list_of_countries_idx = Array.new(given_weight + 1) { Array.new }
    num_of_values = currency.size
    
    for i in 0..given_weight
      beatenIndex = -1
      bestPrevIndex = -1
      for j in 0..num_of_values-1
        if (currency[j].weight < i)
          if (max_values[i] < max_values[i-currency[j].weight] + currency[j].collector_value)
            max_values[i] = max_values[i-currency[j].weight] + currency[j].collector_value
            beatenIndex = j
            bestPrevIndex = i-currency[j].weight.to_i
          end
        end
      end
      list_of_countries_idx[i].push(beatenIndex)
      list_of_countries_idx[i].push(bestPrevIndex)
    end

    last_index = given_weight
    currencies = Array.new
    while last_index > 0
      currencies.push(list_of_countries_idx[last_index][0]) if list_of_countries_idx[last_index][0] > 0
      last_index = list_of_countries_idx[last_index][1]
    end
    
    countries = Array.new
    currencies.each do |currency_idx|
      countries.push(currency[currency_idx].country.name)
    end

    respond_to do |format|
        format.json { render :json => countries.as_json }
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

    if options[:visited].to_s.strip != '' then
      options[:visited] = CGI::unescape(options[:visited])
      conditions_stmt += ' AND ' unless conditions_stmt == ''
      conditions_stmt += 'visited = "' + (options[:visited] == 'true' ? 't' : 'f') + '"'
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
    
    Rails.logger.debug {"Search conditions: #{conditions_stmt}"}
    conditions_stmt
  end
end
