require 'spec_helper'
require 'poke/log'

module Poke
  describe Log do

    Given(:log)    { double }
    Given(:app)    { double }
    Given { allow(app).to receive(:call).and_return(response) }
    Given(:logger) { described_class.new app, output: log }
    Given(:response) do
      [ 200,
        { 'Content-Type' => 'text/plain' },
        [ 'response content' ]
      ]
    end

    Given(:env) do
      {
        'PATH_INFO'      => path,
        'REQUEST_METHOD' => method
      }
    end
    Given(:path)   { '/abc123' }
    Given(:method) { 'GET'     }

    When { ENV['LOG_LEVEL'] = log_level }
    When { logger.call env }

    context 'logging is turned off' do
      Given(:log_level) { 'OFF' }
      Given { expect(log).to_not receive(:put) }
      Then  { 'nothing happens' }
    end

    context 'logging is set to DEBUG' do
      Given(:log_level) { 'DEBUG' }
      Given { expect(log).to receive(:print).twice }
      Given { expect(log).to receive(:printf).at_least(:twice) }
      Then  { 'logging happens' }
    end
  end
end
