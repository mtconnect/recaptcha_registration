
Redmine::Plugin.register :recaptcha_register do
  name 'Recaptcha Register plugin'
  author 'William Sobel'
  description 'Recaptcha protection for the register page'
  version '0.9.1'
  url 'https://github.com/mtconnect/recaptcha_register'
  author_url 'https://wvsobel.llc'

  settings :default => {
     'recaptcha_site_key' => '',
     'recaptcha_secret_key' => '',
     'recaptcha_message' => '',
     'recaptcha_submit' => ''
  }, :partial => 'settings/recaptcha'
end

begin
  Rails.configuration.to_prepare do
    require_dependency 'patches/recaptcha_setting_patch'
    require_dependency 'patches/recaptcha_account_controller_patch'
    unless Setting.included_modules.include?(Patches::RecaptchaSettingPatch)
      Setting.include(Patches::RecaptchaSettingPatch)
    end
    unless AccountController.included_modules.include?(Patches::RecaptchaAccountControllerPatch)
      AccountController.include(Patches::RecaptchaAccountControllerPatch)
    end
  end
  
  if ActiveRecord::Base.connection.table_exists?(Setting.table_name)
    Rails.application.config.after_initialize do
      settings = Setting['plugin_recaptcha_register']
      Recaptcha.configure do |config|
        config.site_key  = settings['recaptcha_site_key']
        config.secret_key = settings['recaptcha_secret_key']
      end
    end
  end
rescue ActiveRecord::NoDatabaseError
  Rails.logger.warn 'database not created yet'
end

