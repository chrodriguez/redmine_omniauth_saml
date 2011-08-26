require File.expand_path('../../test_helper', __FILE__)

class RedmineOmniAuthCASTest < ActiveSupport::TestCase
  context "#cas_service_validate_url" do
    should "return setting if not blank" do
      url = "cas.example.com/validate"
      Setting["plugin_redmine_omniauth_cas"]["cas_service_validate_url"] = url
      assert_equal url, Redmine::OmniAuthCAS.cas_service_validate_url
    end

    should "return nil if setting is blank" do
      Setting["plugin_redmine_omniauth_cas"]["cas_service_validate_url"] = ""
      assert_equal nil, Redmine::OmniAuthCAS.cas_service_validate_url
    end
  end
end
