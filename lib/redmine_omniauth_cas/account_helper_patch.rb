module Redmine::OmniAuthCAS
  module AccountHelperPatch
    def label_for_cas_login
      Redmine::OmniAuthCAS.label_login_with_cas.presence || l(:label_login_with_cas)
    end
  end
end
AccountHelper.send(:include, Redmine::OmniAuthCAS::AccountHelperPatch)
