require 'net/http'
require 'net/https'
module LamAuth
  module Model
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def find_by_access_token(access_token)
        Rails.logger.info("Trying to authorize a token #{access_token.inspect} ")

        uri = URI.parse(LamAuth.url)
        http = Net::HTTP.new(uri.host, uri.port)
        response = http.get("#{uri.path}/users/me", {'Authorization' => "Token token=\"#{access_token}\""})
        if response.code == "200"
          data = ActiveSupport::JSON.decode(response.body)
          Rails.logger.info("...success: #{data.inspect}")
          create_or_update_by_auth_data(data)
        else
          Rails.logger.info("...failed with #{response.code}!")
          nil
        end
      end

      def create_or_update_by_auth_data(data)
        user = find_or_initialize_by_login(data['login'])
        user.update_attributes! data.slice(*%w{email first_name last_name}).merge(
          'userpic' => data['userpic']['icon'], 
          'profile' => data.except(*%w{login email first_name last_name userpic})
        )
        user
      end
    end
  end
end