module MTConnectRegister
  module AccountControllerPatch
    def self.included(base)
      base.prepend(InstanceMethods)
    end

    module InstanceMethods
      def register(&block)
        (redirect_to(home_url); return) unless Setting.self_registration? || session[:auth_source_registration]
        if request.post?
          session[:auth_source_registration] = nil
          @user = User.new(:language => current_language.to_s)
          @user.safe_attributes = params[:user] || {}
          @user.pref.safe_attributes = params[:pref]
          
          verified = verify_recaptcha(action: 'register', minumum_score: 0.5, model: @user)
          
          if !verified
            flash.now[:error] = "Please prove you are not a robot"
            return
          end
          
          @user = nil
        end
        
        super(&block)
      end
    end
  end
end
