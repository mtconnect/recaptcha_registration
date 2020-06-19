
Redmine::Plugin.register :recaptcha_register do
  name 'Recaptcha Register plugin'
  author 'William Sobel'
  description 'Recaptcha protection for the register page'
  version '0.9.1'
  url 'https://github.com/mtconnect/recaptcha_register'
  author_url 'https://wvsobel.llc'

  settings :default => {
     'recaptcha_site_key' => '',
     'Recaptcha_secret_key' => ''
  }, :partial => 'settings/recaptcha'
end

begin
  Rails.configuration.to_prepare do
    require_dependency 'patches/setting_patch'
    require_dependency 'patches/account_controller_patch'
    unless Setting.included_modules.include?(RecaptchaRegister::SettingPatch)
      Setting.include(RecaptchaRegister::SettingPatch)
    end
    unless AccountController.included_modules.include?(RecaptchaRegister::AccountControllerPatch)
      AccountController.include(RecaptchaRegister::AccountControllerPatch)
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

