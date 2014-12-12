require 'spec_helper'

describe Poke::Stash do
  Given(:status)  { OpenStruct.new Poke::Base::STATUS_MAP }
  Given(:store)   { {} }
  Given(:content) { 'some content' }
  Given(:stash)   { described_class.new datastore: store }
  Given(:path)    { '/abc123' }
  Given(:env) do
    {
      'PATH_INFO'      => path,
      'REQUEST_METHOD' => method
    }
  end
  Given(:json_item) do
    { content_type: 'text/html',
      content:      [ content ]
    }.to_json
  end

  When(:result) { stash.call env }

  describe 'GET' do
    Given(:method) { 'GET' }

    context "item not in datastore" do
      Then { result.first == status.not_found }
    end

    context "item IS in datastore" do
      Given { store[path] = json_item }
      Then { result == [ status.ok, { "Content-Type" => "text/html" }, [ content ] ] }
    end
  end

  describe 'POST' do
    Given(:method) { 'POST' }
    Given { env['CONTENT_TYPE'] = 'text/html' }

    context "item not in datastore" do
      Given { env['rack.input']   = StringIO.new content }
      Then  { store[path] == json_item }
    end

    context "item is in datastore" do
      Given { store[path] = json_item }
      Given { env['rack.input']   = StringIO.new 'some other content' }
      Then  { JSON.parse(store[path])['content'] == [ content ] }
      Then  { result.first == status.forbidden }
    end
  end

end
