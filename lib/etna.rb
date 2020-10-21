require 'json'
require_relative './etna/ext'
require_relative './etna/logger'
require_relative './etna/server'
require_relative './etna/command'
require_relative './etna/errors'
require_relative './etna/route'
require_relative './etna/application'
require_relative './etna/controller'
require_relative './etna/auth'
require_relative './etna/test_auth'
require_relative './etna/parse_body'
require_relative './etna/cross_origin'
require_relative './etna/describe_routes'
require_relative './etna/client'
require_relative './etna/symbolize_params'
require_relative './etna/spec'
require_relative './etna/clients'
require_relative './etna/environment_scoped'

class EtnaApp
  include Etna::Application
end
