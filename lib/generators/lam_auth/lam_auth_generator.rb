module LamAuth
  module Generators
    class LamAuthGenerator < Rails::Generators::Base
      namespace "lam_auth"
      source_root File.expand_path("../../templates", __FILE__)

      desc "Installs lam_auth"
      
      def copy_xd_receiver
        copy_file 'xd_receiver.html', 'public/xd_receiver.html'
      end
      
      def copy_yml
        copy_file 'lam_auth.yml', 'config/lam_auth.yml'
      end
    end
  end
end
