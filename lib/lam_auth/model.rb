require 'net/http'
require 'net/https'
module LamAuth
  module Model
    def self.included(base)
      base.validates_presence_of :login, :email
      base.validates_uniqueness_of :login, :email
      base.serialize :profile
      base.send(:extend, ClassMethods)
    end
    
    module ClassMethods
      def find_by_access_token(access_token)
        Rails.logger.info("Trying to authorize a token #{access_token.inspect} ")

        lam_uri = LamAuth.uri
        http = Net::HTTP.new(lam_uri.host, lam_uri.port)
        response, body = http.get("#{lam_uri.path}/users/me", {'Authorization' => "Token token=\"#{access_token}\""})
        if response.code == "200"
          data = ActiveSupport::JSON.decode(body)
          Rails.logger.info("...success: #{data.inspect}")
          create_or_update_by_auth_data(data)
        else
          Rails.logger.info("...failed with #{response.code}!")
          nil
        end
      rescue Net::ProtoRetriableError => detail
        Rails.logger.info("...failed!")
        Rails.logger.info(detail)
        nil
      end

      def create_or_update_by_auth_data(data)
        user = find_or_initialize_by_login(data['login'])
        user.update_attributes data.slice(*%w{email first_name last_name}).merge(
          'userpic' => data['userpic']['icon'], 
          'profile' => data.except(*%w{login email first_name last_name userpic})
        )
        user
      end
    end
    
    def name
      [first_name, last_name].select(&:present?).join(" ")
    end
    
    def userpic(version = :icon)
      pic = read_attribute(:userpic)
      return nil if pic.blank?
      pic.sub(/user-userpic-\w+/, "user-userpic-#{version}")
    end  
    
  end
end