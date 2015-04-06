$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), '..', 'app'))

require 'rspec/given'
require 'ostruct'
require 'timecop'
require 'pry'
require 'digest/sha2'
require 'rack/mock'
require 'json'
