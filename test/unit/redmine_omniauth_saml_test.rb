require File.expand_path('../../test_helper', __FILE__)

class RedmineOmniAuthSAMLTest < ActiveSupport::TestCase
  context "#enabled?" do
    should "return enabled? if setting is set" do
      Setting["plugin_redmine_omniauth_saml"]["enabled"] = false
      assert !Redmine::OmniAuthSAML.enabled?
    end
  end

  context "#settings_hash" do
    should "return all needed attributes" do
      %w{enabled onthefly_creation replace_redmine_login label_login_with_saml}.each do |key|
        assert Redmine::OmniAuthSAML.settings_hash.key?(key), "Expected key #{key} not present in settings_hash"
      end
    end
  end

  context "#onthefly_creation?" do
    should "return onthefly_creation false if setting is set and plugin is disabled" do
      Setting["plugin_redmine_omniauth_saml"]["onthefly_creation"] = true
      assert !Redmine::OmniAuthSAML.onthefly_creation?
    end

    should "return onthefly_creation if setting is set and plugin is enabled" do
      Setting["plugin_redmine_omniauth_saml"]["onthefly_creation"] = true
      Setting["plugin_redmine_omniauth_saml"]["enabled"] = true
      assert Redmine::OmniAuthSAML.onthefly_creation?
    end
  end

  context "#label_login_with_saml" do
    should "return label_login_with_saml if setting is set" do
      val = '1234'
      Setting["plugin_redmine_omniauth_saml"]["label_login_with_saml"] = val
      assert_equal val, Redmine::OmniAuthSAML.label_login_with_saml
    end
  end
end
