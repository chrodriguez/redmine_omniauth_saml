require 'redmine'
require 'redmine_omniauth_saml'
require 'redmine_omniauth_saml/hooks'
require 'redmine_omniauth_saml/user_patch'


# Patches to existing classes/modules
ActiveSupport::Reloader.to_prepare do
  require_dependency 'redmine_omniauth_saml/account_helper_patch'
  require_dependency 'redmine_omniauth_saml/account_controller_patch'
end

# Plugin generic informations
Redmine::Plugin.register :redmine_omniauth_saml do
  name 'Redmine Omniauth SAML plugin'
  description 'This plugin adds Omniauth SAML support to Redmine. Based in Omniauth CAS plugin'
  author 'Christian A. Rodriguez'
  author_url 'mailto:car@cespi.unlp.edu.ar'
  url 'https://github.com/chrodriguez/redmine_omniauth_saml'
  version '0.0.1'
  requires_redmine :version_or_higher => '2.3.0'
  settings :default => { 'enabled' => 'true', 'label_login_with_saml' => '', 'replace_redmine_login' => false  },
           :partial => 'settings/omniauth_saml_settings'
end

