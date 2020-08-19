require_relative '../../json_serializable_struct'
require_relative '../../multipart_serializable_nested_hash'
require_relative '../../directed_graph'

# TODO:  In the near future, I'd like to transition to specifying apis via SWAGGER and generating model stubs from the
# common definitions.  For nowe I've written them out by hand here.
module Etna
  module Clients
    class Magma
      class RetrievalRequest < Struct.new(:model_name, :attribute_names, :record_names, :project_name, keyword_init: true)
        include JsonSerializableStruct

        def initialize(**params)
          super({model_name: 'all', attribute_names: 'identifier', record_names: []}.update(params))
        end
      end

      class QueryRequest < Struct.new(:query, :project_name, keyword_init: true)
        include JsonSerializableStruct
      end

      class UpdateRequest < Struct.new(:revisions, :project_name, keyword_init: true)
        include JsonSerializableStruct

        def initialize(**params)
          super({revisions: {}}.update(params))
        end

        def update_revision(model_name, record_name, **attrs)
          revision = revisions[model_name] ||= {}
          record = revision[record_name] ||= {}
          record.update(attrs)
        end
      end

      class UpdateModelRequest < Struct.new(:project_name, :actions, keyword_init: true)
        include JsonSerializableStruct
        include MultipartSerializableNestedHash

        def initialize(**params)
          super({actions: []}.update(params))
        end

        def add_action(action)
            actions << action
        end
      end

      class AddAttributeAction < Struct.new(:model_name, :attribute_name, :type, :description, :display_name, :format_hint, :hidden, :index, :link_model_name, :read_only, :restricted, :unique, :validation, keyword_init: true)
        include JsonSerializableStruct
      end

      class AttributeValidation < Struct.new(:type, :value, :begin, :end, keyword_init: true)
        include JsonSerializableStruct
      end

      class AttributeValidationType < String
        REGEXP = AttributeValidationType.new("Regexp")
        ARRAY = AttributeValidationType.new("Array")
        RANGE = AttributeValidationType.new("Range")
      end

      class RetrievalResponse
        attr_reader :raw

        def initialize(raw = {})
          @raw = raw
        end

        def models
          Models.new(raw['models'])
        end
      end

      class UpdateModelResponse < RetrievalResponse
      end

      class QueryResponse
        attr_reader :raw

        def initialize(raw = {})
          @raw = raw
        end

        def answer
          raw['answer']
        end

        def format
          raw['format']
        end

        def type
          raw['type']
        end
      end

      class UpdateResponse < RetrievalResponse
      end

      class Models
        attr_reader :raw

        def initialize(raw = {})
          @raw = raw
        end

        def model_keys
          raw.keys
        end

        def model(model_key)
          Model.new(raw[model_key])
        end

        def to_directed_graph(include_casual_links=false)
          graph = ::DirectedGraph.new

          model_keys.each do |model_name|
            graph.add_connection(model(model_name).template.parent, model_name)

            if include_casual_links
              attributes = model(model_name).template.attributes
              attributes.attribute_keys.each do |attribute_name|
                linked_model_name = attributes.attribute(attribute_name).link_model_name
                if linked_model_name
                  graph.add_connection(model_name, linked_model_name)
                end
              end
            end
          end

          graph
        end
      end

      class Model
        attr_reader :raw

        def initialize(raw = {})
          @raw = raw
        end

        def documents
          Documents.new(raw['documents'])
        end

        def template
          Template.new(raw['template'])
        end
      end

      class Documents
        attr_reader :raw

        def initialize(raw = {})
          @raw = raw
        end

        def document_keys
          raw.keys
        end

        def document(document_key)
          raw[document_key]
        end
      end

      class Template
        attr_reader :raw

        def initialize(raw = {})
          @raw = raw
        end

        def name
          raw['name'] || ""
        end

        def identifier
          raw['identifier'] || ""
        end

        def parent
          raw['parent']
        end

        def attributes
          Attributes.new(raw['attributes'])
        end
      end

      class Attributes
        attr_reader :raw

        def initialize(raw = {})
          @raw = raw
        end

        def attribute_keys
          raw.keys
        end

        def attribute(attribute_key)
          Attribute.new(raw[attribute_key])
        end
      end

      class Attribute
        attr_reader :raw

        def initialize(raw = {})
          @raw = raw
        end

        def name
          @raw['name'] || ""
        end

        def attribute_name
          @raw['attribute_name'] || ""
        end

        def type
          @raw['type'] && AttributeType.new(@raw['type'])
        end

        def link_model_name
          raw['link_model_name']
        end
      end

      class AttributeType < String
        STRING = AttributeType.new("string")
        DATE_TIME = AttributeType.new("date_time")
        BOOLEAN = AttributeType.new("boolean")
        CHILD = AttributeType.new("child")
        COLLECTION = AttributeType.new("collection")
        FILE = AttributeType.new("file")
        FLOAT = AttributeType.new("float")
        IDENTIFIER = AttributeType.new("identifier")
        IMAGE = AttributeType.new("image")
        INTEGER = AttributeType.new("integer")
        LINK = AttributeType.new("link")
        MATCH = AttributeType.new("match")
        MATRIX = AttributeType.new("matrix")
        PARENT = AttributeType.new("parent")
        TABLE = AttributeType.new("table")
      end
    end
  end
end