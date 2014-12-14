require 'spec_helper'
require 'poke/store'

describe Poke::Store do

  Given(:hash) { {} }
  Given { allow_any_instance_of(described_class).to receive(:store).and_return(hash) }
  Given(:store) { described_class.new }
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

    Then  { expect(result).to eq({ content_type: 'text/plain', content: [ content ] }) }
  end
end
