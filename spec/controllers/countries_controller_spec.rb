require File.expand_path(File.dirname(__FILE__) + '/../rails_helper')
require 'rspec/rails'
require 'database_cleaner'

describe CountriesController do
#   before(:all) do
#     DatabaseCleaner.clean_with(:truncation)
#     load "#{Rails.root}/db/seeds.rb"
#   end
  describe "Test Countries Controller methods" do
    
    it "should GET index and return all countries" do
      sign_in
      request.accept = "application/json"
      get :index
      expect(response).to be_success
      parsed_body = JSON.parse(response.body)
      expect(parsed_body["total"]).to eq(244)
    end

    it "should GET index and return with search name" do
      sign_in
      request.accept = "application/json"
      get :index, :per_page => 10, :page => 1, :sort => 'name asc', :search => true, :name => 'Albania'
      expect(response).to be_success
      parsed_body = JSON.parse(response.body)
      expect(parsed_body["rows"].size).to eq(1)
    end

    it "should GET index and return with search id" do
      sign_in
      request.accept = "application/json"
      get :index, :per_page => 10, :page => 1, :sort => 'name asc', :search => true, :id => 'us'
      expect(response).to be_success
      parsed_body = JSON.parse(response.body)
      expect(parsed_body["total"]).to eq(1)
    end

    it "should GET index and return with search visited" do
      sign_in
      request.accept = "application/json"
      get :index, :per_page => 10, :page => 1, :sort => 'name asc', :search => true, :visited => 'false'
      expect(response).to be_success
      parsed_body = JSON.parse(response.body)
      expect(parsed_body["total"]).to eq(244)
    end

    it "should GET country with code USD" do
      sign_in
      request.accept = "application/json"
      get :show, :id => 'us'
      expect(response).to be_success
      parsed_body = JSON.parse(response.body)
      expect(parsed_body["name"]).to eq('United States')
    end

    it "should GET visited status for country with code us" do
      sign_in
      request.accept = "application/json"
      get :show, :id => 'us', :visited => true
      expect(response).to be_success
      expect(response.body).to eq('false')
    end

    it "should GET countries visited over time" do
      sign_in
      request.accept = "application/json"
      get :visited_over_time
      expect(response).to be_success
    end

    it "should GET countries visited vs not_visited" do
      sign_in
      request.accept = "application/json"
      get :visited_vs_notvisited
      expect(response).to be_success
      parsed_body = JSON.parse(response.body)
      expect(parsed_body["not_visited"]).to eq(244)
    end
  
  end

end