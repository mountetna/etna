require 'webmock/rspec'
require 'json'
require_relative '../../../lib/etna/clients/polyphemus'

describe 'Polyphemus Client class' do
  let(:test_class) { Etna::Clients::Polyphemus.new(token: 'fake-token', host: 'https://polyphemus.test') }

  before(:each) do
    stub_polyphemus_setup
  end

  it 'can fetch the configuration' do
    test_class.configuration(Etna::Clients::Polyphemus::ConfigurationRequest.new)
    expect(WebMock).to have_requested(:get, /#{POLYPHEMUS_HOST}\/configuration/)
  end

  it 'can submit a job' do
    test_class.job(Etna::Clients::Polyphemus::JobRequest.new(
      model_names: "all",
      redcap_tokens: ["123"],
      project_name: PROJECT
    )) do |body_fragment|
      expect(body_fragment).to eq('success!')
    end
    expect(WebMock).to have_requested(:post, /#{POLYPHEMUS_HOST}\/#{PROJECT}\/job/)
  end
end