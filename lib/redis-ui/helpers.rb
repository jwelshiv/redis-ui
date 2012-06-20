# -*- coding: utf-8 -*-
module RedisUIHelpers
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
             '???'
           end

    {:key => key, :type => redis.type(key), :data => data}
  end

  def show(val)
    case val
    when String
      val
    when Array
      if val.empty?
        '[]'
      else
        str = "<ul><li> · "
        str << val.map{|v|show(v)}.join('</li><li> · ')
        str << '</li></ul>'
      end
    when Hash
      str = "<ul><li> · "
      arr = []
      val.map do |k, v|
        arr << "#{k} => #{show(v)}"
      end
      str << arr.join("</li><li> · ")
      str << '</li></ul>'
    else
      val.to_s
    end
  end

  def render_tree(val)
    str = "<ul>"
    val.each do |k, v|
      str << "<li><a href='#'>#{k}</a>#{render_tree(v)}</li>"
    end
    str << '</ul>'
  end

  def build_namespace_tree
    @namespace_tree = {}
    namespaces = redis.keys.map{|k| k.split(':')[0..-2]}.uniq.sort_by(&:size)
    namespaces.each do |array|
      hash = array.reverse.inject({}) do |branch, string|
        newtrunk = {}
        newtrunk[string] = branch
        newtrunk
      end
      @namespace_tree.deep_merge!(hash)
    end
  end
  # {
  #   'top' => {
  #     'second' => {}
  #   }
  # }

end
