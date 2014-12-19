require 'spec_helper'
require 'poke/stash'

describe Poke::Stash do
  Given(:status)  { OpenStruct.new Poke::Base::STATUS_MAP }
  Given(:store)   { {} }
  Given(:content) { 'some content' }
  Given { Poke::ItemStore.datastore = store }
  Given(:stash)   { described_class.new }
  Given(:path)    { '/abc123' }
  Given(:env) do
    {
      'PATH_INFO'      => path,
      'REQUEST_METHOD' => method
    }
  end
  Given(:item) do
    { content_type: 'test/plain',
      content:      [ content ]
    }
  end

  When(:result) { stash.call env }

  describe 'GET' do
    Given(:method) { 'GET' }

    context 'item not in datastore' do
      Then { result.first == status.not_found }
    end

    context 'item IS in datastore' do
      Given { store[path] = Marshal.dump(item) }
      Then { result == [ status.ok, { 'Content-Type' => 'test/plain' }, [ content ] ] }
    end
  end

  describe 'POST' do
    Given(:method) { 'POST' }
    Given { env['CONTENT_TYPE'] = 'test/plain' }

    context 'item not in datastore' do
      Given { env['rack.input']   = StringIO.new content }
      Then  { store[path] == Marshal.dump(item) }
    end

    context 'item is in datastore' do
      Given { store[path] = item }
      Given { env['rack.input']   = StringIO.new 'some other content' }
      Then  { store[path][:content] == [ content ] }
      Then  { result.first == status.forbidden }
    end
  end

end
