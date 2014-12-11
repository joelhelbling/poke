$LOAD_PATH.unshift File.expand_path(File.join('.', 'lib'))

require 'ostruct'
require 'rack'
require 'poke'
if ENV['RACK_ENV'] == 'development'
  require 'pry'
end

run Poke.new
