require File.expand_path('../../../test_helper', __FILE__)

class AccountHelperPatchTest < ActionView::TestCase
  include Redmine::OmniAuthCAS::AccountHelperPatch
  include Redmine::I18n

  context "#label_for_cas_login" do
    should "use label_login_with_cas plugin setting if not blank" do
      label = "Log in with SSO"
      Setting["plugin_redmine_omniauth_cas"]["label_login_with_cas"] = label
      assert_equal label, label_for_cas_login
    end

    should "default to localized :label_login_with_cas if no setting present" do
      assert_equal l(:label_login_with_cas), label_for_cas_login
    end
  end
end
