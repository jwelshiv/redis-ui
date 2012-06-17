require 'redis'
require 'redis/namespace'
require 'pp'

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
    set :public_folder, File.dirname(__FILE__) + '/static'
      
    helpers do 
      include Rack::Utils
      alias_method :h, :escape_html

      def redis
        RedisUI.redis
      end
      
      def get_key(key)
        data = case redis.type(key)
               when "string"
                 redis[key]
               when "list"
                 redis.lrange(key, 0, -1)
               when "set"
                 redis.smembers(key)
               when 'zset'
                 redis.zrange(key, 0, -1)
               when 'hash'
                 redis.hgetall(key)
               else
                 []
               end

        {:key => key, :type => redis.type(key), :data => data}
      end

      def show(val)
        case val
        when String
          val
        when Array
          str = "<ul><li>"
          str << val.join('</li><li>')
          str << '</li></ul>'
        when Hash
          str = "<ul><li>"
          arr = []
          val.map do |k, v|
            arr << "#{k} => #{v}"
          end
          str << arr.join('</li><li>')
          str << '</li></ul>'
        else
          val.to_s
        end
      end
      
    end
    
    get "/" do
      @keys = RedisUI.redis.keys.map{ |key| get_key(key) }
      erb :index
    end
    
    get "/keys" do
      content_type :json
      @keys = {:keys => RedisUI.redis.keys.map{ |key| get_key(key) }}
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
