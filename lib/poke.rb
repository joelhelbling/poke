require 'dotenv'
Dotenv.load

require 'rack'
require 'leveldb'
require 'poke/base'
require 'poke/stash'
require 'poke/about'

module Poke

  def self.app
    Poke::Stash.new( datastore: Poke.datastore )
  end

  def self.datastore
    LevelDB::DB.new ENV['LEVELDB_STORE']
  end
end
