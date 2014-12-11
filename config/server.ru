$LOAD_PATH.unshift File.expand_path(File.join('.', 'lib'))

require 'dotenv'
Dotenv.load

require 'leveldb'
require 'rack'
require 'poke/stash'
require 'poke/about'

if ENV['RACK_ENV'] == 'development'
  require 'pry'
end

use Poke::About

datastore = LevelDB::DB.new ENV['LEVELDB_STORE']
run Poke::Stash.new( datastore: datastore )
