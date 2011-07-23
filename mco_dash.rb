require 'rubygems' if RUBY_VERSION < "1.9"
require 'sinatra'
require 'sinatra/base'
require 'sinatra/respond_to'
require 'logger'
require 'json'
require 'mcollective'
include MCollective::RPC
require (File.join(File.dirname(__FILE__), 'config', 'environment.rb'))
require 'mcoll'

class Mcodash < Sinatra::Base
  register Sinatra::RespondTo
  #Sinatra::Application.register Sinatra::RespondTo
  set :static, true
  set :public, File.dirname(__FILE__) + '/static'

  configure do
    LOGGER = Logger.new("log/mcodash.log", 7, 'daily')
  end

  helpers do
    def logger
      LOGGER
    end
  end

  get '/' do
    respond_to do |wants|
      wants.html {  erb :index,
			:layout => :main_template }
      end
  end
  
  get '/hostfilter' do
    respond_to do |wants|
      wants.html {  erb :hostform,
			:layout => :main_template }
      end
  end
  
  post '/hostfilter' do
		client = Mcoll::Client.new
		request[:agent] = params[:request].split(":")[0]
		request[:action] = params[:request].split(":")[1]
		response = client.getresults(params[:fact], params[:value], request[:agent], request[:action])
    respond_to do |wants|
      wants.html {  erb :hostresults,
												:layout => :main_template,
												:locals => {:response => response, :request => request}
												}
      wants.json { results.to_json }
    end
    
		
  end
  

end
