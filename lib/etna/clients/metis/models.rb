require_relative '../../json_serializable_struct'


module Etna
  module Clients
    class Metis
      class ListFoldersRequest < Struct.new(:project_name, :bucket_name, :offset, :limit, keyword_init: true)
        include JsonSerializableStruct

        def initialize(**params)
          super({}.update(params))
        end

        def to_h
          # The :project_name comes in from Polyphemus as a symbol value,
          #   we need to make sure it's a string because it's going
          #   in the URL.
          super().compact.transform_values(&:to_s)
        end
      end

      class RenameFolderRequest < Struct.new(:project_name, :bucket_name, :folder_path, :new_bucket_name, :new_folder_path, :create_parent, keyword_init: true)
        include JsonSerializableStruct

        def initialize(**params)
          super({create_parent: false}.update(params))
        end

        def to_h
          # The :project_name comes in from Polyphemus as a symbol value,
          #   we need to make sure it's a string because it's going
          #   in the URL.
          super().compact.transform_values(&:to_s)
        end
      end

      class ListFolderRequest < Struct.new(:project_name, :bucket_name, :folder_path, keyword_init: true)
        include JsonSerializableStruct

        def initialize(**params)
          super({}.update(params))
        end

        def to_h
          # The :project_name comes in from Polyphemus as a symbol value,
          #   we need to make sure it's a string because it's going
          #   in the URL.
          super().compact.transform_values(&:to_s)
        end
      end

      class CreateFolderRequest < Struct.new(:project_name, :bucket_name, :folder_path, keyword_init: true)
        include JsonSerializableStruct

        def initialize(**params)
          super({}.update(params))
        end

        def to_h
          # The :project_name comes in from Polyphemus as a symbol value,
          #   we need to make sure it's a string because it's going
          #   in the URL.
          super().compact.transform_values(&:to_s)
        end
      end

      class FoldersResponse
        attr_reader :raw

        def initialize(raw = {})
          @raw = raw
        end

        def folders
          Folders.new(raw[:folders])
        end
      end

      class FoldersAndFilesResponse < FoldersResponse
        def files
          Files.new(raw[:files])
        end
      end

      class Files
        attr_reader :raw

        def initialize(raw = {})
          @raw = raw
        end

        def all
          raw.map { |file| File.new(file) }
        end
      end

      class Folders
        attr_reader :raw

        def initialize(raw = {})
          @raw = raw
        end

        def all
          raw.map { |folder| Folder.new(folder) }
        end
      end

      class File
        attr_reader :raw

        def initialize(raw = {})
          @raw = raw
        end

        def file_path
          raw[:file_path]
        end

        def file_name
          raw[:file_name]
        end
      end

      class Folder
        attr_reader :raw

        def initialize(raw = {})
          @raw = raw
        end

        def folder_path
          raw[:folder_path]
        end

        def bucket_name
          raw[:bucket_name]
        end
      end
    end
  end
end