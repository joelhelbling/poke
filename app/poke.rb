require 'dotenv'
Dotenv.load

require 'rack'
require 'squares'
require 'leveldb'
require 'poke/stash'
require 'poke/about'
require 'poke/quota_api'
require 'poke/enforce_quotas'

storage_dir = ENV['LEVELDB_STORAGE_DIR'] || './tmp'
Squares.each do |model|
  model.store = LevelDB::DB.new( "#{storage_dir}/#{model.underscore_name}_storage" )
end

module Poke
  def self.app
    Poke::Stash.new
  end
end
