require 'spec_helper'
require 'poke/store'

module Poke

  class TestStore < Store
    def handle_unmarshal_error item
      "handle_type_error: #{item}"
    end
  end

  describe Store do

    Given(:hash) { {} }
    Given { TestStore.datastore = hash }
    Given(:store)   { TestStore.new }
    Given(:content) { { bar: 'bop'} }

    describe 'stores as marshalled' do
      Given { store['foo'] = content }
      Then  { hash == { 'foo' => Marshal.dump(content) } }
    end

    describe 'parses marshalled items found in datastore' do
      Given { hash['pho'] = Marshal.dump content }
      Then  { store['pho'] == content }
    end

    describe 'non-JSON found in datastore' do
      Given(:content) { "plain string will not parse" }
      Given { hash['/not/json'] = content }

      When(:result) { store['/not/json'] }

      Then  { expect(result).to eq("handle_type_error: #{content}") }
    end
  end
end
