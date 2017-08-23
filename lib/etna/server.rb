# This class handles the http request and routing
module Etna
  class Server
    class << self
      def route path, method=nil, action=nil, &block
        @routes ||= {}

        @routes[path] = Etna::Route.new(
          method,
          action,
          &block
        )
      end

      def get path, action=nil, &block
        route(path, 'GET', action, &block)
      end
      
      def post path, action=nil, &block
        route(path, 'POST', action, &block)
      end

      def put path, action=nil, &block
        route(path, 'PUT', action, &block)
      end

      def delete path, action=nil, &block
        route(path, 'DELETE', action, &block)
      end

      attr_reader :routes
    end

    def call(env)
      @request = Rack::Request.new(env)

      @request.env['rack.errors'] = @logger

      if self.class.routes.has_key? @request.path
        return self.class.routes[@request.path].call(self, @request)
      end

      [ 404, {}, ["There is no such path '#{@request.path}'"] ]
    end

    def initialize config

      # setup the application, since we are
      # booting through the rack server
      application.configure(config)

      # setup logging
      setup_logger
    end

    private

    # The base application class is a singleton
    # independent of this rack server, holding e.g.
    # configuration
    def application
      @application ||= Etna::Application.find(self.class)
    end

    def setup_logger
      @logger = Logger.new(
        # The name of the log_file, required
        application.config(:log_file),
        # Number of old copies of the log to keep
        application.config(:log_copies || 5),
        # How large the log can get before overturning
        application.config(:log_size || 1048576)
      )
      @logger.level = Logger::WARN
    end
  end
end
