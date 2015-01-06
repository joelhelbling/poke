$LOAD_PATH.unshift File.expand_path(File.join('.', 'lib'))

if ENV['RACK_ENV'] == 'development'
  require 'pry'
end

require 'async-rack'
require 'poke'

use Poke::About
use Poke::EnforceQuotas
run Poke.app
