require 'redmine'

# Plugin generic informations
Redmine::Plugin.register :redmine_omniauth_cas do
  name 'Redmine Omniauth plugin'
  description 'This plugin adds Omniauth support to Redmine'
  author 'Jean-Baptiste BARTH'
  author_url 'mailto:jeanbaptiste.barth@gmail.com'
  url 'http://github.com/jbbarth/redmine_omniauth_cas'
  version '0.0.1'
end

# Hooks
require 'redmine_omniauth_cas/hooks'

# OmniAuth basics
require 'omniauth/core'
require 'omniauth/oauth'

# Patches to existing classes/modules
config.to_prepare do
  require_dependency 'redmine_omniauth_cas/account_controller_patch'
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
config.middleware.use OmniAuth::Strategies::CAS, :cas_server => 'http://localhost:9292'
