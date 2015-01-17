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
      context 'GET' do
        Given(:method) { 'GET' }
        context '/about' do
          Given(:path) { '/about' }
          Then do
            result == [ status.ok, { "Content-Type" => "text/html" }, [ about.about_content ] ]
          end
        end
        context '/about/' do
          Given(:path) { '/about/' }
          Then do
            result == [ status.moved_permanently, { "Location" => '/about' }, [] ]
          end
        end
        context '/' do
          Given(:path) { '/' }
          Then do
            result == [ status.moved_permanently, { "Location" => '/about' }, [] ]
          end
        end
      end
      context 'POST' do
        Given(:path) { '/' }
        Given(:method) { 'POST' }
        Then { result.first == status.not_allowed }
      end
    end
  end
end
