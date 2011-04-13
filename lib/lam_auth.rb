require 'rack/utils'
require 'digest/md5'

require 'lam_auth/controller_extensions'
require 'lam_auth/helpers'
require 'lam_auth/model'
ActionController::Base.extend(LamAuth::ControllerExtensions)
ActionController::Base.helper(LamAuth::Helpers)

module LamAuth
  class LoginRequiredException < Exception
  end
  
  class << self
    def config
      @config ||= YAML.load_file(Rails.root.join("config/lam_auth.yml"))[Rails.env]
    end
    
    def url
      "http://www.lookatme.ru"
    end
    
    def signup_url
      "#{url}/signup"
    end
    
    def uri
      URI.parse(url)
    end
    
    def cookie_id
      "lam_#{config['app_id']}"
    end
    
    def valid_cookie?(data)
      valid_hash?(parse_cookie_to_hash(data))
    end
    
    def parse_cookie_to_hash(data)
      Rack::Utils.parse_query(Rack::Utils.unescape(data.to_s.gsub('"', '')))
    end
    
    def valid_hash?(hash)
      Digest::MD5.hexdigest(hash.except('sig').sort.map{|v| v.join('=')}.join + LamAuth.config['secret']) == hash['sig']
    end
  end
end

