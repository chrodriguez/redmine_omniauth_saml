module Redmine::OmniAuthCAS
  class << self
    def settings_hash
      Setting["plugin_redmine_omniauth_cas"]
    end

    def enabled?
      settings_hash["enabled"]
    end

    def cas_server
      settings_hash["cas_server"]
    end

    def cas_service_validate_url
      settings_hash["cas_service_validate_url"].presence || nil
    end

    def label_login_with_cas
      settings_hash["label_login_with_cas"]
    end
  end
end
