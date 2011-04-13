module LamAuth
  module Helpers
    def lam_auth_include_tag
      javascript_include_tag(LamAuth.url + "/api/js/LAM.Login.js")
    end
  
    def lam_auth_init_tag(options = {})
      options.reverse_merge!(
        :app_id          => LamAuth.config['app_id'],
        :panel_node_id   => 'lam-root', 
        :fixed           => false
      )      
      options.reverse_merge!(:xd_receiver_url => LamAuth.config['return_url']) if LamAuth.config['return_url']
      
      javascript_tag("LAM.init({#{options.map{|k, v| "#{k.to_s.camelize(:lower)}: #{v.inspect}"}.join(",\n")}});")
    end
  end
end
