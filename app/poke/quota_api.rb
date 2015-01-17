require 'json'
require 'rack/request'
require 'poke/rack_tools'
require 'models/quota'

module Poke
  class QuotaApi
    include RackTools

    def initialize(app)
      @app = app
    end

    def call(env)
      req = Rack::Request.new env

      if match = req.path.match(/^\/quotas\/?(.*)$/)
        id = match[1]
        if id.empty?
          if req.get?
            render_content all_quotas
          else
            decline(req)
          end
        else # we have a key
          if req.get?
            quota = Quota.find(id)
            render_content payload_for(quota).to_json
          elsif req.put?
            params = symbolize_hash JSON.parse(req.body.readlines.join)
            put_quota id, params
            render_content []
          elsif req.delete?
            Quota.delete id
            render_content []
          end
        end
      else
        defer_to_app(req)
      end
    end

    private

    def put_quota(id, params)
      if Quota.key?(id)
        quota = Quota.find id
        quota.quota_in_minutes = params[:quota_in_minutes]
        quota.max_tokens = params[:max_tokens]
        quota.save
      else
        Quota.create id, params
      end
    end

    def defer_to_app(req)
      @app.call req.env
    end

    def all_quotas
      # paginate?  What kind of support does leveldb have for that?  Or other hashlikes?
      Quota.map{ |quota| payload_for(quota) }.to_json
    end

    def payload_for(quota)
        quota.to_h(:quota).tap { |h| h.delete(:last_generated_token) }
    end

    def render_content(content)
      render content_type: 'application/json', content: content
    end

    def symbolize_hash(hash)
      hash.inject({}) do |h,pair|
        h.tap{ |hash| hash[pair.first.to_sym] = pair.last }
      end
    end

  end
end
