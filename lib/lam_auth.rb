require 'rack/utils'
require 'digest/md5'

require 'lam_auth/helpers'
require 'lam_auth/model'
ActionController::Base.helper(LamAuth::Helpers)

module LamAuth
  class << self
    def app
      @app ||= YAML.load_file(Rails.root.join("config/lam_auth.yml"))
    end

    def config
      {
        'lookatme' => {
          'prefix' => 'lam', 
          'url' => 'http://www.lookatme.ru',
          'api' => 'LAM',
          'api_url' => 'http://www.lookatme.ru/api/js/LAM.Login.js',
        },
        'village' => {
          'prefix' => 'village', 
          'url' => 'http://www.the-village.ru',
          'api' => 'VLG',
          'api_url' => 'http://assets0.the-village.ru/api/js/VLG.Login.js',
        }
      }[site]
    end

    def site
      %w{lookatme village}.include?(app['site']) ? app['site'] : 'lookatme'
    end
    
    def url
      config['url']
    end
    
    def cookie_id
      "#{config['prefix']}_#{app['app_id']}"
    end

    def access_token_from_cookie(cookie)
      hash = parse_cookie_to_hash(cookie)
      valid_hash?(hash) && hash['access_token']
    end
    
    def parse_cookie_to_hash(data)
      Rack::Utils.parse_query(Rack::Utils.unescape(data.to_s.gsub('"', '')))
    end
    
    def valid_hash?(hash)
      Digest::MD5.hexdigest(hash.except('sig').sort.map{|v| v.join('=')}.join + app['secret']) == hash['sig']
    end
  end
end

