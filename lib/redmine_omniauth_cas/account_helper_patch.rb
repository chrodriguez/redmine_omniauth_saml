module Redmine::OmniAuthCAS
  module AccountHelperPatch
    def label_for_cas_login
      Setting["plugin_redmine_omniauth_cas"]["label_login_with_cas"].presence || l(:label_login_with_cas)
    end
  end
end
AccountHelper.send(:include, Redmine::OmniAuthCAS::AccountHelperPatch)
