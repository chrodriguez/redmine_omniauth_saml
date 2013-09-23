require File.expand_path('../../test_helper', __FILE__)

#let's use the existing functional test so we don't have to re-setup everything
#+ we are sure that existing tests pass each time we run this file only
require Rails.root.join('test/functional/account_controller_test')

class AccountControllerTest
  fixtures :users, :roles

  context "GET /login SAML button" do
    should "show up only if there's a plugin setting for SAML URL" do
      Setting["plugin_redmine_omniauth_saml"]["enabled"] = false
      get :login
      assert_select '#saml-login', 0
      Setting["plugin_redmine_omniauth_saml"]["enabled"] = true
      get :login
      assert_select '#saml-login'
    end
  end

  context "GET login_with_saml_callback" do
    setup do
      RedmineSAML[:attribute_mapping] = {
        'login'      => 'login',
        'firstname'  => 'first_name',
        'lastname'   => 'last_name',
        'mail'       => 'mail'
      }
      Setting["plugin_redmine_omniauth_saml"]["enabled"] = true
    end

    should "redirect to /my/page after successful login" do
      request.env["omniauth.auth"] = {"login"=>"admin"}
      get :login_with_saml_callback, :provider => "saml"
      assert_redirected_to '/my/page'
    end

    should "redirect to /login after failed login" do
      request.env["omniauth.auth"] = {"login"=>"non-existent"}
      get :login_with_saml_callback, :provider => "saml"
      assert_redirected_to '/login'
    end

    should "set a boolean in session to keep track of login" do
      request.env["omniauth.auth"] = {"login"=>"admin"}
      get :login_with_saml_callback, :provider => "saml"
      assert_redirected_to '/my/page'
      assert session[:logged_in_with_saml]
    end

    should "redirect to Home if not logged in with SAML" do
      get :logout
      assert_redirected_to home_url
    end

    should "redirect to SAML logout if previously logged in with SAML" do
      RedmineSAML[:logout_admin] = "http://saml.server/logout?return="
      session[:logged_in_with_saml] = true
      get :logout
      assert_redirected_to "#{RedmineSAML[:logout_admin]}http://test.host/"
    end

  end
end
