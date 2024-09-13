require 'dotenv'
Dotenv.load

require 'rack'
# Remove any require 'async-rack' if it exists
require 'squares'
require 'lmdb'
require 'poke/version'
require 'poke/log'
require 'poke/stash'
require 'poke/about'
require 'poke/quota_api'
require 'poke/enforce_quotas'

storage_dir = ENV['LMDB_STORAGE_DIR'] || './tmp'
env = LMDB.new(storage_dir)

Squares.each do |model|
  model.store = env.database("#{model.underscore_name}_storage")
end

module Poke
  def self.app
    Poke::Stash.new
  end
end
