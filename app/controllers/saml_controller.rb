class SamlController < ApplicationController
  unloadable

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

