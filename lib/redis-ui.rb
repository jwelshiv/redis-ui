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
    
  # Returns the current Redis connection. If none has been created, will
  # create a new one.
  def self.redis
    return @redis if @redis
    @redis = Redis.new
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