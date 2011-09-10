require 'hiredis'
require 'redis/namespace'

begin
  require 'yajl'
rescue LoadError
  require 'json'
end

require 'sinatra/base'
require 'sinatra/respond_to'
require 'erb'

module RedisUI
  extend self
  
  # hostname:port
  # redis://hostname:port
  def redis=(server)    
    case server
    when String
      if server =~ /redis\:\/\//
        redis = Redis.connect(:url => server, :thread_safe => true)
      else
        server, namespace = server.split('/', 2)
        host, port, db = server.split(':')
        redis = Redis.new(:host => host, :port => port,
          :thread_safe => true, :db => db)
      end
      namespace ||= ""
      
      @redis = Redis::Namespace.new(namespace, :redis => redis)
    
    when Redis::Namespace
      @redis = server
    else
      @redis = Redis::Namespace.new(@namespace, :redis => server)
    end
  end

  def redis
    return @redis if @redis
    self.redis = Redis.respond_to?(:connect) ? Redis.connect : "localhost:6379"
    self.redis
  end
   
  
  class Server < Sinatra::Base
    register Sinatra::RespondTo
    
    set :sessions, true
    set :logging, true
    set :views, File.dirname(__FILE__) + '/views'
    set :public, File.dirname(__FILE__) + '/static'
      
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