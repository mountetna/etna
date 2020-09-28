require 'webmock/rspec'
require 'json'

describe Etna::Clients::Magma::UpdateAttributesFromCsvWorkflow do
  let(:magma_client) {Etna::Clients::Magma.new(
      token: '123',
      host: MAGMA_HOST)}
  let(:magma_crud) {Etna::Clients::Magma::MagmaCrudWorkflow.new(
      magma_client: magma_client, project_name: PROJECT)}

  before(:each) do
    @all_updates = []
    stub_magma_models(
      JSON.parse(File.read('./spec/fixtures/magma/magma_test_model.json')))
    stub_magma_update
  end

  def updates
    @all_updates.inject({}) do |acc, n|
      n.keys.each do |k|
        (acc[k] ||= {}).update(n[k])
      end
      acc
    end
  end

  it 'raises exception for rows that are too short' do
    workflow = Etna::Clients::Magma::UpdateAttributesFromCsvWorkflow.new(
      magma_crud: magma_crud,
      project_name: PROJECT,
      filepath: './spec/fixtures/magma/magma_update_attributes_short_row.csv'
    )

    expect {
      workflow.update_attributes
    }.to raise_error(
      RuntimeError,
      'Invalid revision row ["model_two", "234", "weight"]. Must include at least 4 column values (model,record_name,attribute_name,attribute_value).')

    expect(WebMock).not_to have_requested(:post, /#{MAGMA_HOST}\/update/)
  end

  it 'raises exception for rows that are missing data' do
    workflow = Etna::Clients::Magma::UpdateAttributesFromCsvWorkflow.new(
      magma_crud: magma_crud,
      project_name: PROJECT,
      filepath: './spec/fixtures/magma/magma_update_attributes_missing_data.csv'
    )

    expect {
      workflow.update_attributes
    }.to raise_error(
      RuntimeError,
      'Invalid revision row ["model_two", "123", "name", "Record #123", "strength", "2", "invisible"]. Must have an even number of columns.')

    expect(WebMock).not_to have_requested(:post, /#{MAGMA_HOST}\/update/)
  end

  it 'raises exception for invalid models' do
    workflow = Etna::Clients::Magma::UpdateAttributesFromCsvWorkflow.new(
      magma_crud: magma_crud,
      project_name: PROJECT,
      filepath: './spec/fixtures/magma/magma_update_attributes_invalid_model.csv'
    )

    expect {
      workflow.update_attributes
    }.to raise_error(RuntimeError, 'Invalid model fake_model for project test.')

    expect(WebMock).not_to have_requested(:post, /#{MAGMA_HOST}\/update/)
  end

  it 'sends valid revisions to magma' do
    workflow = Etna::Clients::Magma::UpdateAttributesFromCsvWorkflow.new(
      magma_crud: magma_crud,
      project_name: PROJECT,
      filepath: './spec/fixtures/magma/magma_update_attributes_valid.csv'
    )

    workflow.update_attributes

    expect(updates).to eq({
      "model_two" => {
        "234" => {"height" => "64.2","invisible" => "true"},
        "123" => {"name" => "Record #123","strength" => "2","invisible" => "1"}
      },
      "model_one" => {
        "xyz" => {"name" => "First model of the day"},
        "098" => {"name" => ""},
      }
    })

    expect(WebMock).to have_requested(:post, /#{MAGMA_HOST}\/update/)
  end

  it 'raises exception for invalid attribute name' do
    workflow = Etna::Clients::Magma::UpdateAttributesFromCsvWorkflow.new(
      magma_crud: magma_crud,
      project_name: PROJECT,
      filepath: './spec/fixtures/magma/magma_update_attributes_invalid_attribute.csv'
    )

    expect {
      workflow.update_attributes
    }.to raise_error(RuntimeError, 'Invalid attribute weight for model model_two.')

    expect(WebMock).not_to have_requested(:post, /#{MAGMA_HOST}\/update/)
  end

  it 'raises exception for invalid filename' do
    workflow = Etna::Clients::Magma::UpdateAttributesFromCsvWorkflow.new(
      magma_crud: magma_crud,
      project_name: PROJECT,
      filepath: './spec/fixtures/magma/nonexistent_input.csv'
    )

    expect {
      workflow.update_attributes
    }.to raise_error(StandardError)

    expect(WebMock).not_to have_requested(:post, /#{MAGMA_HOST}\/update/)
  end
end