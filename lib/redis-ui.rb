begin
	require 'sinatra/base'
rescue LoadError
  require 'rubygems'
  require 'sinatra/base'
end
require 'sinatra/respond_to'
require 'erb'
require 'redis'
require 'redis-namespace'
require 'json'

module RedisUI
    
  # Accepts:
  #   1. A 'hostname:port' string
  #   2. A 'hostname:port:db' string (to select the Redis db)
  #   3. A 'hostname:port/namespace' string (to set the Redis namespace)
  #   4. A redis URL string 'redis://host:port'
  #   5. An instance of `Redis`, `Redis::Client`, `Redis::DistRedis`, or `Redis::Namespace`
  def self.redis=(server)
    if server.respond_to? :split
      if server =~ /redis\:\/\//
        redis = Redis.connect(:url => server)
      else
        server, namespace = server.split('/', 2)
        host, port, db = server.split(':')
        redis = Redis.new(:host => host, :port => port,
          :thread_safe => true, :db => db)
      end
      
      @redis = Redis::Namespace.new(namespace, :redis => redis)
    elsif server.respond_to? :namespace=
        @redis = server
    else
      @redis = Redis::Namespace.new(:resque, :redis => server)
    end
  end

  # Returns the current Redis connection. If none has been created, will
  # create a new one.
  def self.redis
    return @redis if @redis
    self.redis = 'localhost:6379'
    self.redis
  end
  
  
  class Server < Sinatra::Base
    register Sinatra::RespondTo
    
    set :sessions, true
    set :logging, true
    
    configure do
      set :views, File.dirname(__FILE__) + '/views'
      set :redis, Redis.new('/tmp/redis.sock')
      set :public, File.dirname(__FILE__) + '/static'
    end  
      
    helpers do 
      include Rack::Utils
      alias_method :h, :escape_html
      
      def get_key(key)
        data = case RedisUI.redis.type(key)
        when "string"
          Array(RedisUI.redis[key])
        when "list"
          RedisUI.redis.lrange(key, 0, -1)
        when "set"
          RedisUI.redis.smembers(key)
        else
          []
        end
        
        {:key => key, :type => RedisUI.redis.type(key), :data => data}
      end
      
    end
    
    get "/" do
      @keys = RedisUI.redis.keys.collect{ |key| get_key(key) }
      erb :index
    end
    
    get "/keys" do
      content_type :json
      @keys = {:keys => RedisUI.redis.keys.collect{ |key| get_key(key) }}
      @keys.to_json
    end

    get "/keys/:id" do
      @key = params[:id]
      @data = get_key(@key)
      
      respond_to do |wants|
          wants.html { erb :show }      # => views/posts.html.haml, also sets content_type to text/html
          wants.js { @data.to_json }
      end
    end

    get "/server" do
      {
        :info => RedisUI.redis.info,
        :dbsize => RedisUI.redis.dbsize,
        :lastsave => RedisUI.redis.lastsave,
        :config => RedisUI.redis.config(:get, "*")
      }.to_json
    end

  end
end