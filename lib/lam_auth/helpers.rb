module LamAuth
  module Helpers
    def lam_auth_include_tag
      javascript_include_tag(LamAuth.config['api_url'])
    end
  
    def lam_auth_init_tag(options = {})
      options.reverse_merge!(
        :app_id          => LamAuth.app['app_id'],
        :panel_node_id   => "#{LamAuth.config['prefix']}-root", 
        :fixed           => false
      )      
      options.reverse_merge!(:xd_receiver_url => LamAuth.app['return_url']) if LamAuth.app['return_url']
      
      javascript_tag("#{LamAuth.config['api']}.init({#{options.map{|k, v| "#{k.to_s.camelize(:lower)}: #{v.inspect}"}.join(",\n")}});")
    end
  end
end
