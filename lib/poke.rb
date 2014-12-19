require 'dotenv'
Dotenv.load

require 'rack'
require 'leveldb'
require 'poke/store'
require 'poke/base'
require 'poke/stash'
require 'poke/about'
require 'poke/quota'

module Poke

  ItemStore.datastore        = LevelDB::DB.new( ENV['LEVELDB_ITEM']         || './tmp/item_store'         )
  ItemMetaStore.datastore    = LevelDB::DB.new( ENV['LEVELDB_ITEM_META']    || './tmp/item_meta_store'    )
  TokenChainStore.datastore  = LevelDB::DB.new( ENV['LEVELDB_TOKEN_CHAIN']  || './tmp/token_chain_store'  )
  TokenAnchorStore.datastore = LevelDB::DB.new( ENV['LEVELDB_TOKEN_ANCHOR'] || './tmp/token_anchor_store' )

  def self.app
    Poke::Stash.new
  end

end
