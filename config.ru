$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

begin
	require 'json'
rescue LoadError
	require 'rubygems'
	require 'json'
end

require 'lib/redis-ui'
run RedisUI::Server