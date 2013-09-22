module Redmine::OmniAuthSAML
  class << self
    def settings_hash
#      Setting["plugin_redmine_omniauth_cas"]
      {
        'enabled' => true,
        'replace_redmine_login' => true
      }
    end

    def enabled?
      settings_hash["enabled"]
    end

    def saml_server
      settings_hash["saml_server"]
    end

    def saml_logout_url
      settings['saml_logout_url']
    end

    def cas_service_validate_url
      settings_hash["cas_service_validate_url"].presence || nil
    end

    def label_login_with_saml
      settings_hash["label_login_with_saml"]
    end
  end
end
