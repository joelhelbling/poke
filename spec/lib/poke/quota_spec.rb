require 'spec_helper'

class Poke::Quota

  def initialize(anchor, available_codes={})
    @app = app
    @db = LevelDB::DB.new ENV['LEVELDB_QUOTA']
  end

  def call(env)

  end
end

describe Poke::AuthChain do

  context "sending first valid unused code" do
    Then { :success }
  end
  context "sending second valid unused code" do
    Then { :success_with_index_of_first_skipped }
  end
  context "sending valid but used code" do
    Then { :fail_with_index_of_next_valid }
  end
  context "sending first anchor code" do
    Then { :fail_with_index_of_next_valid }
  end
end
