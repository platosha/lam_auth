module LamAuth
  module ControllerExtensions
    def lam_auth_for(klass)
      class_inheritable_writer :user_model_class
      self.user_model_class = klass
      
      helper_method(:current_user, :logged_in?)
      before_filter :login_from_cookie
      
      extend ClassMethods
      include InstanceMethods
      protected :logged_in?, :current_user, :current_user=, :access_token, :login_from_cookie, :login_required
    end
    
    module ClassMethods
      def user_model_class
        read_inheritable_attribute(:user_model_class).to_s.classify.constantize
      end
    end
    
    module InstanceMethods
      def logged_in?
        !!current_user
      end
  
      def current_user
        @current_user ||= session[:user] && self.class.user_model_class.find_by_id(session[:user])
      end
  
      def current_user=(new_user)
        session[:user] = new_user && new_user.id
        @current_user = new_user
      end
  
      def access_token
        cookie = cookies[LamAuth.cookie_id]
        LamAuth.valid_cookie?(cookie) && LamAuth.parse_cookie_to_hash(cookie)['access_token']
      end
  
      def login_from_cookie
        if logged_in?
          !access_token && self.current_user = nil
        else
          access_token && self.current_user = self.class.user_model_class.find_by_access_token(access_token)
        end
      end
  
      def login_required
        logged_in? || raise(LoginRequiredException)
      end
    end
  end
end
