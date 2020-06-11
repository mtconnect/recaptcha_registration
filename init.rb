
Redmine::Plugin.register :mtconnect_register do
  name 'MTConnect Register plugin'
  author 'William Sobel'
  description 'Additional content for the register page'
  version '0.0.1'
  url 'https://projects.mtconnect.org'
  author_url ''

  settings :default => {
     'recaptcha_site_key' => '',
     'Recaptcha_secret_key' => ''
  }, :partial => 'settings/recaptcha'
end

begin
  Rails.configuration.to_prepare do
    require_dependency 'patches/setting_patch'
    require_dependency 'patches/account_controller_patch'
    unless Setting.included_modules.include?(MTConnectRegister::SettingPatch)
      Setting.include(MTConnectRegister::SettingPatch)
    end
    unless AccountController.included_modules.include?(MTConnectRegister::AccountControllerPatch)
      AccountController.include(MTConnectRegister::AccountControllerPatch)
    end
  end
  
  if ActiveRecord::Base.connection.table_exists?(Setting.table_name)
    Rails.application.config.after_initialize do
      settings = Setting['plugin_mtconnect_register']
      Recaptcha.configure do |config|
        config.site_key  = settings['recaptcha_site_key']
        config.secret_key = settings['recaptcha_secret_key']
      end
    end
  end
rescue ActiveRecord::NoDatabaseError
  Rails.logger.warn 'database not created yet'
end

