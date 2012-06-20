# -*- coding: utf-8 -*-
require 'redis'
require 'redis/namespace'
require 'deep_merge'
require 'pp'
require 'cgi'

begin
  require 'yajl'
rescue LoadError
  require 'json'
end

require 'sinatra/base'
require 'sinatra/respond_to'
require 'erb'

require 'redis-ui/helpers'

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

  def namespace
    @namespace
  end
   
  
  class Server < Sinatra::Base
    register Sinatra::RespondTo
    
    set :sessions, true
    set :logging, true
    set :views, File.dirname(__FILE__) + '/views'
    set :public_folder, File.dirname(__FILE__) + '/static'
    set :assume_xhr_is_js, false
      
    configure :development do
      enable :logging
    end

    helpers do 
      include Rack::Utils
      alias_method :h, :escape_html
      include RedisUIHelpers
    end
    
    get "/" do
      keys = RedisUI.redis.keys
      build_namespace_tree(keys)
      @keys = keys.map{ |key| get_key(key) }
      erb :index
    end

    get "/namespace/:ns" do
      ns = Redis::Namespace.new(params[:ns], :redis => redis)
      @keys = ns.keys.map{|k| get_key(k, ns)}
      build_namespace_tree(redis.keys)
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

    post "/del/:key" do
      result = redis.del(params[:key])
      if result == 1
        true
      else
        500
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
