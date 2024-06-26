module Patches
  module RecaptchaAccountControllerPatch
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

          logger.info "Trying to register account: #{@user.login}: #{@user.firstname} #{@user.lastname}"
          if @user.firstname == @user.lastname or @user.language == 'sq'
            verified = false
            logger.error "An attempt was made to create an account for #{@user.login}: #{@user.firstname} == #{@user.lastname}"
          else          
            verified = verify_recaptcha(action: 'register', minumum_score: 0.9, model: @user)
          end
          
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

