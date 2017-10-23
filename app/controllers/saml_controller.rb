class SamlController < ApplicationController
  unloadable

  # prevents login action to be filtered by check_if_login_required application scope filter
  skip_before_action :check_if_login_required, :check_password_change

  def metadata
    if !saml_settings["enabled"]
        raise ActionController::RoutingError.new('Not Found')        
    end
    settings = OneLogin::RubySaml::Settings.new omniauth_saml_settings
    metadata = OneLogin::RubySaml::Metadata.new
    output = metadata.generate settings
    render :text => output, :content_type => 'application/xml'
  end
  
private
  def saml_settings
    Redmine::OmniAuthSAML.settings_hash
  end

  def omniauth_saml_settings
    Redmine::OmniAuthSAML.configured_saml
  end
end

