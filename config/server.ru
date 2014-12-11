$LOAD_PATH.unshift File.expand_path(File.join('.', 'lib'))

require 'dotenv'
Dotenv.load

require 'leveldb'
require 'rack'
require 'poke'

if ENV['RACK_ENV'] == 'development'
  require 'pry'
end

datastore = LevelDB::DB.new ENV['LEVELDB_STORE']
run Poke.new( datastore: datastore )
