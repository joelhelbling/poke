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

  def self.app
    Poke::Stash.new
  end

end
