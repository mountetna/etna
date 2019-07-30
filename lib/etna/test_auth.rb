require_relative 'user'

# This is an authentication layer you can use in testing. It will make an
# Etna::User as usual that your controller can respond to; you can pass
# permissions for this user directly in the Authorization header
module Etna
  class TestAuth
    def self.token_header(params)
      token = Base64.strict_encode64(params.to_json)
      return [ 'Authorization', "Etna #{token}" ]
    end

    def self.hmac_header(params)
      token = Base64.strict_encode64(params.to_json)
      return [ 'Authorization', "Hmac #{token}" ]
    end

    def initialize(app)
      @app = app
    end

    def application
      @application ||= Etna::Application.instance
    end

    def server
      @server ||= application.class.const_get(:Server)
    end

    def failure(status, msg)
      [ status, {}, [ msg] ]
    end

    def auth(type)
      (@request.env['HTTP_AUTHORIZATION'] || 'Missing header')[/\A#{type.capitalize} (.*)\z/,1]
    end

    def user_auth
      token = auth(:etna)

      return false unless token

      # here we simply base64-encode our user hash and pass it through
      payload = JSON.parse(Base64.decode64(token))

      @request.env['etna.user'] = Etna::User.new(payload.map{|k,v| [k.to_sym, v]}.to_h)
    end

    def hmac_auth
      token = auth(:hmac)

      return false unless token

      # here we simply base64-encode our user hash and pass it through
      payload = JSON.parse(Base64.decode64(token), symbolize_names: true)

      @request.env['rack.request.params'].update(payload)
      @request.env['etna.hmac'] = true
    end

    def no_auth
      route = server.find_route(@request)

      return route && route.noauth?
    end

    def call(env)
      @request = Rack::Request.new(env)

      unless no_auth
        return failure(401, 'Authorization header missing') if auth(:missing)

        return failure(401, 'Authorization header malformed') unless hmac_auth || user_auth
      end
      @app.call(env)
    end
  end
end
