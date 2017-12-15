describe Etna::Server do
  include Rack::Test::Methods

  attr_reader :app

  before(:each) do
    class Arachne
      include Etna::Application
      class Server < Etna::Server; end
    end
    class WebController < Etna::Controller
      def silk
        success('text/html', 'ok')
      end
    end
  end

  after(:each) do
    Object.send(:remove_const, :Arachne)
    Object.send(:remove_const, :WebController)
  end

  context 'routing' do
    it 'should allow route definitions with blocks' do
      Arachne::Server.route('GET', '/silk') do
        [ 200, {}, [ 'ok' ] ]
      end
      @app = setup_app(Arachne::Server.new(test: {}))

      get '/silk'

      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq('ok')
    end

    it 'should allow route definitions with actions' do
      Arachne::Server.route('GET', '/silk', action: 'web#silk')
      @app = setup_app(Arachne::Server.new(test: {}))

      get '/silk'
      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq('ok')
    end

    it 'supports various method verbs' do
      Arachne::Server.get('/silk') { [ 200, {}, [ 'get' ] ] }
      Arachne::Server.post('/silk') { [ 200, {}, [ 'post' ] ] }
      Arachne::Server.put('/silk') { [ 200, {}, [ 'put' ] ] }
      Arachne::Server.delete('/silk') { [ 200, {}, [ 'delete' ] ] }
      @app = setup_app(Arachne::Server.new(test: {}))

      get '/silk'
      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq('get')

      post '/silk'
      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq('post')

      put '/silk'
      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq('put')

      delete '/silk'
      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq('delete')
    end

    it 'matches routes without an initial /' do
      Arachne::Server.get('weaver/:name') { [ 200, {}, [ @params[:name] ] ] }
      @app = setup_app(Arachne::Server.new(test: {}))

      get '/weaver/Arachne'

      expect(last_response.body).to eq('Arachne')
    end

    it 'parses route parameters' do
      Arachne::Server.get('/silk/:thread_weight/:shape') do
        [ 200, {}, [ "#{@params[:thread_weight]}-#{@params[:shape]}" ] ]
      end
      @app = setup_app(Arachne::Server.new(test: {}))

      get '/silk/25/octagon'

      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq('25-octagon')
    end

    it 'allows route globbing with slashes' do
      description = 'A tapestry/weave of the Olympians.'
      Arachne::Server.get('/silk/*description') do
        [ 200, {}, [ @params[:description] ] ]
      end
      @app = setup_app(Arachne::Server.new(test: {}))

      get URI.encode("/silk/#{description}")

      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq(description)
    end

    it 'sets route names' do
      Arachne::Server.get('/silk/:name', as: :silk_road)

      expect(Arachne::Server.routes.first.name).to eq(:silk_road)
    end

    it 'looks up route names' do
      Arachne::Server.get('/silk/:query', as: :silk) do
        [ 200, {}, [ route_path(:silk, @params) ] ]
      end
      @app = setup_app(Arachne::Server.new(test: {}))

      get('/silk/tree')
      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq('http://example.org/silk/tree')
    end
  end
end