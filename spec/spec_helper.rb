$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'lib'))

require 'rspec/given'
require 'ostruct'
require 'pry'

require 'poke/base'
require 'poke/about'
require 'poke/stash'
