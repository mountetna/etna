module Etna
  class Controller
    def initialize(request, action = nil)
      @request = request
      @action = action
      @response = Rack::Response.new
      @params = @request.env['rack.request.params']
      @errors = []
      @server = @request.env['etna.server']
      @logger = @request.env['etna.logger']
      @user = @request.env['etna.user']
    end

    def log(line)
      @logger.write "#{Time.now.strftime("%d/%b/%Y %H:%M:%S")} #{line}\n"
    end

    def response
      return send(@action) if @action 

      [501, {}, ['This controller is not implemented.']]
    rescue Etna::BadRequest, Etna::ServerError=> e
      return failure(e.status, error: e.message)
    end

    def route_path(name, params={})
      route = @server.class.routes.find do |route|
        route.name.to_s == name.to_s
      end
      return nil if route.nil?
      path = route.path
        .gsub(/:([\w]+)/) { params[$1.to_sym] }
        .gsub(/\*([\w]+)$/) { params[$1.to_sym] }
      @request.scheme + '://' + @request.host + path
    end

    # methods for returning a view
    VIEW_PATH = :VIEW_PATH

    def view(name)
      txt = File.read("#{self.class::VIEW_PATH}/#{name}.html")
      @response['Content-Type'] = 'text/html'
      @response.write(txt)
      @response.finish
    end

    def erb_view(name)
      txt = File.read("#{self.class::VIEW_PATH}/#{name}.html.erb")
      @response['Content-Type'] = 'text/html'
      @response.write(ERB.new(txt).result(binding))
      @response.finish
    end

    private

    def success(content_type, msg)
      @response['Content-Type'] = content_type
      @response.write(msg)
      @response.finish
    end

    def failure(status, msg)
      @response.status = status
      @response.write(msg.to_json)
      @response.finish
    end

    def success?
      @errors.empty?
    end

    def error(msg)
      if msg.is_a?(Array)
        @errors.concat(msg)
      else
        @errors.push(msg)
      end
    end
  end
end
