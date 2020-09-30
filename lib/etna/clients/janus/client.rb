require 'net/http/persistent'
require 'net/http/post/multipart'
require 'singleton'
require_relative './models'

module Etna
  module Clients
    class Janus
      def initialize(host:, token:, persistent: true)
        raise 'Janus client configuration is missing host.' unless host
        raise 'Janus client configuration is missing token.' unless token
        @etna_client = ::Etna::Client.new(host, token, routes_available: false, persistent: persistent)
      end

      def add_project(add_project_request = AddProjectRequest.new)
        @etna_client.post('/add_project', add_project_request) do |res|
          # Redirect, no response data
        end
      end

      def update_permission(update_permission_request = UpdatePermissionRequest.new)
        @etna_client.post(
          "/update_permission/#{update_permission_request.project_name}",
          update_permission_request) do |res|
          # Redirect, no response data
        end
      end

      def refresh_token(refresh_token_request = RefreshTokenRequest.new)
        token = nil
        @etna_client.get('/refresh_token', refresh_token_request) do |res|
          token = res.body
        end

        TokenResponse.new(token)
      end

      def viewer_token(viewer_token_request = ViewerTokenRequest.new)
        token = nil
        @etna_client.get('/viewer_token', viewer_token_request) do |res|
          token = res.body
        end

        TokenResponse.new(token)
      end
    end
  end
end