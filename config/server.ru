$LOAD_PATH.unshift File.expand_path(File.join('.', 'lib'))

require 'ostruct'
require 'rack'
require 'poke'
require 'pry'

run Poke.new
