module MTConnectRegister
  module SettingPatch
    def self.included(base)
      base.singleton_class.prepend(ClassMethods)
    end

    module ClassMethods
      def plugin_mtconnect_register=(settings)
        Recaptcha.configure do |config|
          config.site_key  = settings['recaptcha_site_key']
          config.secret_key = settings['recaptcha_secret_key']
        end

        super(settings)
      end
    end
  end
end
