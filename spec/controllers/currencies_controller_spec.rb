require File.expand_path(File.dirname(__FILE__) + '/../rails_helper')
require 'rspec/rails'
require 'database_cleaner'

describe CurrenciesController do
#   before(:all) do
#     DatabaseCleaner.clean_with(:truncation)
#     load "#{Rails.root}/db/seeds.rb" 
#   end
  describe "Test Currencies Controller methods" do
    
    it "should GET index and return all currencies" do
      sign_in
      request.accept = "application/json"
      get :index
      expect(response).to be_success
      parsed_body = JSON.parse(response.body)
      expect(parsed_body["total"]).to eq(154)
    end

    it "should GET index and return with search name" do
      sign_in
      request.accept = "application/json"
      get :index, :per_page => 10, :page => 1, :sort => 'name asc', :search => true, :name => 'Franc'
      expect(response).to be_success
      parsed_body = JSON.parse(response.body)
      expect(parsed_body["rows"].size).to eq(9)
    end

    it "should GET index and return with search id" do
      sign_in
      request.accept = "application/json"
      get :index, :per_page => 10, :page => 1, :sort => 'name asc', :search => true, :id => 'USD'
      expect(response).to be_success
      parsed_body = JSON.parse(response.body)
      expect(parsed_body["total"]).to eq(1)
    end

    it "should GET index and return with search weight" do
      sign_in
      request.accept = "application/json"
      get :index, :per_page => 10, :page => 1, :sort => 'name asc', :search => true, :weight => '>4.5'
      expect(response).to be_success
      parsed_body = JSON.parse(response.body)
      expect(parsed_body["total"]).to eq(13)

      get :index, :per_page => 10, :page => 1, :sort => 'name asc', :search => true, :weight => '<4.5'
      expect(response).to be_success
      parsed_body = JSON.parse(response.body)
      expect(parsed_body["total"]).to eq(141)
    end

    it "should GET index and return with search collector_value" do
      sign_in
      request.accept = "application/json"
      get :index, :per_page => 10, :page => 1, :sort => 'name asc', :search => true, :collector_value => '>4.5'
      expect(response).to be_success
      parsed_body = JSON.parse(response.body)
      expect(parsed_body["total"]).to eq(83)

      get :index, :per_page => 10, :page => 1, :sort => 'name asc', :search => true, :collector_value => '<4.5'
      expect(response).to be_success
      parsed_body = JSON.parse(response.body)
      expect(parsed_body["total"]).to eq(71)
    end

    it "should GET currency with code USD" do
      sign_in
      request.accept = "application/json"
      get :show, :id => 'USD'
      expect(response).to be_success
      parsed_body = JSON.parse(response.body)
      expect(parsed_body["name"]).to eq('Dollar')
    end

    it "should GET collected status for currency with code USD" do
      sign_in
      request.accept = "application/json"
      get :show, :id => 'USD', :collected => true
      expect(response).to be_success
      expect(response.body).to eq('false')
    end

    it "should GET currencies collected over time" do
      sign_in
      request.accept = "application/json"
      get :collected_over_time
      expect(response).to be_success
    end

    it "should GET currencies collected vs not_collected" do
      sign_in
      request.accept = "application/json"
      get :collected_vs_notcollected
      expect(response).to be_success
      parsed_body = JSON.parse(response.body)
      expect(parsed_body["not_collected"]).to eq(154)
    end
  
  end

end