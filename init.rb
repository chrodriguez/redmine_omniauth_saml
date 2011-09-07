require 'redmine'
require 'redmine_omniauth_cas'
require 'redmine_omniauth_cas/hooks'
require 'omniauth/core'
require 'omniauth/oauth'

# Patches to existing classes/modules
config.to_prepare do
  require_dependency 'redmine_omniauth_cas/account_helper_patch'
  require_dependency 'redmine_omniauth_cas/account_controller_patch'
end

# Plugin generic informations
Redmine::Plugin.register :redmine_omniauth_cas do
  name 'Redmine Omniauth plugin'
  description 'This plugin adds Omniauth support to Redmine'
  author 'Jean-Baptiste BARTH'
  author_url 'mailto:jeanbaptiste.barth@gmail.com'
  url 'http://github.com/jbbarth/redmine_omniauth_cas'
  version '0.1.1'
  requires_redmine :version_or_higher => '1.2.0'
  settings :default => { 'label_login_with_cas' => '', 'cas_server' => '' },
           :partial => 'settings/omniauth_cas_settings'
end

# Full host in case the apps runs behind a reverse-proxy
OmniAuth.config.full_host = Proc.new do |env|
  url = env["omniauth.origin"] || env["rack.session"]["omniauth.origin"]
  #parse url from env and remove both request_uri and query_string
  if url.present?
    uri = URI.parse(url)
    url = "#{uri.scheme}://#{uri.host}"
    url << ":#{uri.port}" unless uri.default_port == uri.port
  #if no url found, fall back to config/app_config.yml addresses
  else
    url = Setting["host_name"]
  end
  url
end

# PROVIDERS

# Sample CAS provider
require 'omniauth/enterprise'
setup_app = Proc.new do |env|
  if Redmine::OmniAuthCAS.cas_server.present?
    hsh = { :cas_server => Redmine::OmniAuthCAS.cas_server }
    hsh[:cas_service_validate_url] = Redmine::OmniAuthCAS.cas_service_validate_url if Redmine::OmniAuthCAS.cas_service_validate_url.present?
    config = OmniAuth::Strategies::CAS::Configuration.new(hsh)
    env['omniauth.strategy'].instance_variable_set(:@configuration, config)
  end
end
config.middleware.use OmniAuth::Strategies::CAS, :cas_server => 'http://localhost:9292', :setup => setup_app
