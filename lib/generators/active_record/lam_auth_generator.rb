require 'rails/generators/active_record'
require 'generators/lam_auth/helpers'

module ActiveRecord
  module Generators
    class LamAuthGenerator < ActiveRecord::Generators::Base
      include LamAuth::Generators::Helpers
      source_root File.expand_path("../templates", __FILE__)

      def generate_model
        invoke "active_record:model", [name], :migration => false unless model_exists? && behavior == :invoke
      end

      def copy_lam_auth_migration
        migration_template "migration.rb", "db/migrate/create_#{table_name}"
      end

      def inject_lam_auth_content
        inject_into_class(model_path, class_name, model_contents) if model_exists?
      end
    end
  end
end
