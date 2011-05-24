#!/usr/bin/env ruby
require 'logger'

$LOAD_PATH.unshift ::File.expand_path(::File.dirname(__FILE__) + '/lib')
require 'lib/redis-ui'

use Rack::ShowExceptions
run RedisUI::Server.new