require 'spec_helper'
require 'poke/about'
require 'poke/rack_tools'

module Poke
  describe About do
    Given(:status) { OpenStruct.new RackTools::STATUS_MAP }
    Given(:app) { double }
    Given(:about) { described_class.new app }
    Given(:env) do
      {
        'PATH_INFO'      => path,
        'REQUEST_METHOD' => method
      }
    end
    Given(:method) { 'GET' }

    When(:result) { about.call env }

    describe "non-watched path" do
      Given(:path) { '/abc123' }
      context "GET" do
        Given(:method) { 'GET' }
        Given { expect(app).to receive(:call).with(env) }
        Then { 'app is called' }
      end
      context "POST" do
        Given(:method) { 'POST' }
        Given { expect(app).to receive(:call).with(env) }
        Then { 'app is called' }
      end
    end

    describe "watched paths" do
      Given(:path) { described_class::WATCHED_PATHS.sample }
      context 'GET' do
        Given(:method) { 'GET' }
        Then do
          result == [ status.ok, { "Content-Type" => "text/plain" }, [ described_class::ABOUT_CONTENT ] ]
        end
      end
      context 'POST' do
        Given(:method) { 'POST' }
        Then { result.first == status.not_allowed }
      end
    end
  end
end
