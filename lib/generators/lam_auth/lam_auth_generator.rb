module LamAuth
  module Generators
    class LamAuthGenerator < Rails::Generators::NamedBase
      namespace "lam_auth"
      source_root File.expand_path("../../templates", __FILE__)

      desc "Installs lam_auth: generates a model plus includes required extensions."
      
      hook_for :orm
      
      def inject_controller_content
        inject_into_class(File.join("app", "controllers", "application_controller.rb"), 'ApplicationController', "  lam_auth_for :#{file_path}\n")
      end
      
      def copy_xd_receiver
        copy_file 'xd_receiver.html', 'public/xd_receiver.html'
      end
      
      def copy_yml
        copy_file 'lam_auth.yml', 'config/lam_auth.yml'
      end
      
      def show_readme
        readme "README" if behavior == :invoke
      end
    end
  end
end
