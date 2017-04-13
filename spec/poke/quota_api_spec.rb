require 'spec_helper'
require 'models/quota'
require 'json'
require 'poke/quota_api'

module Poke
  describe QuotaApi do
    Given { Quota.store = {} }
    Given(:status) { OpenStruct.new RackTools::STATUS_MAP }
    Given(:app)    { double }
    Given(:api)    { described_class.new app }
    Given(:env) do
      Rack::MockRequest.env_for "http://localhost:9995#{path}",
        'REQUEST_METHOD' => method
    end
    Given do
      Quota.create( 'abc123', quota_in_minutes: 5*24*60, max_tokens: 10_000 )
      Quota.create( 'def456', quota_in_minutes: 3*24*60, max_tokens: 5_000  )
    end

    When(:result) { api.call env }

    context 'a non-quotas path' do
      Given(:method) { 'GET' }
      Given(:path)   { '/abc123' }
      Given { expect(app).to receive(:call).with(env) }
      Then  { 'app is called' }
    end

    describe 'GET /quotas' do
      Given(:method) { 'GET' }
      Given(:path)   { '/quotas' }
      Given(:expected_json) do
        [
          {
            type:              'Quota',
            quota:             'abc123',
            quota_in_minutes:  5*24*60,
            quota_in_accesses: 5,
            limit_accesses?:   true,
            max_tokens:        10_000
          },
          {
            type:              'Quota',
            quota:             'def456',
            quota_in_minutes:  3*24*60,
            quota_in_accesses: 5,
            limit_accesses?:   true,
            max_tokens:        5_000
          }
        ].to_json
      end

      Then { expect(result[2].first).to eq(expected_json) }
    end

    describe 'GET /quotas/abc123' do
      Given(:method) { 'GET' }
      Given(:path)   { '/quotas/abc123' }
      Given(:expected_json) do
        {
          type:              'Quota',
          quota:             'abc123',
          quota_in_minutes:  5*24*60,
          quota_in_accesses: 5,
          limit_accesses?:   true,
          max_tokens:        10_000
        }.to_json
      end

      Then { expect(result[2].first).to eq(expected_json) }
    end

    describe 'PUT /quotas/ghi789' do
      Given(:method) { 'PUT' }
      Given(:path)   { '/quotas/ghi789' }
      Given(:json_payload) do
        {
          quota_in_minutes:  4,
          quota_in_accesses: 12,
          limit_accesses?:   true,
          max_tokens:        7
        }.to_json
      end
      Given { env['rack.input'] = StringIO.new json_payload }

      context 'non-preexistant quota' do
        Then { expect(Quota['ghi789']).to_not be_nil }
        Then { expect(Quota['ghi789'].quota_in_minutes).to eq(4) }
      end

      context 'preexistant quota' do
        Given do
          Quota.create 'ghi789',
            quota_in_minutes:     8,
            limit_accesses?:      false,
            max_tokens:           14,
            last_generated_token: 'c0ff33'
        end
        Then { expect(Quota['ghi789'].quota_in_minutes).to eq(4) }
        Then { expect(Quota['ghi789'].quota_in_accesses).to eq(12) }
        Then { expect(Quota['ghi789']).to be_limit_accesses }
        Then { expect(Quota['ghi789'].max_tokens).to eq(7) }
        Then { expect(Quota['ghi789'].last_generated_token).to eq('c0ff33') }
      end
    end

    describe 'DELETE /quotas/abc123' do
      Given(:method) { 'DELETE' }
      Given(:path)   { '/quotas/abc123' }

      Then { expect(Quota['abc123']).to be_nil }
    end

  end
end
