module RedisUI
  require 'rubygems'
  require 'sinatra/base'
  require 'redis'
  require 'json'
  
  def self.redis
    Redis.new
  end
  
  class Server < Sinatra::Base

    configure do
      set :views, File.dirname(__FILE__) + '/views'
      set :redis, Redis.new('/tmp/redis.sock')
      set :public, File.dirname(__FILE__) + '/static'
    end  
      
    helpers do 
      # helpers go here
    end
    
    
    get "/" do
      @keys = RedisUI.redis.keys
      #@keys.to_json
      erb :index
    end
    
    get "/index" do
      "Welcome"
    end

    get "/:key" do
      @key = params[:key]
      @data = case RedisUI.redis.type(@key)
      when "string"
        Array(RedisUI.redis[@key])
      when "list"
        RedisUI.redis.lrange(@key, 0, -1)
      when "set"
        RedisUI.redis.set_members(@key)
      else
        []
      end
      erb :show
    end

  end
end