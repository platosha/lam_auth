module LamAuth
  module Generators
    module Helpers
      def model_exists?
        File.exists?(File.join(destination_root, model_path))
      end

      def model_path
        @model_path ||= File.join("app", "models", "#{file_path}.rb")
      end
      
      def model_contents
<<-CONTENT
  include LamAuth::Model
CONTENT
      end
    end
  end
end