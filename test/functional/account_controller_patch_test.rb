require File.expand_path('../../test_helper', __FILE__)

#let's use the existing functional test so we don't have to re-setup everything
#+ we are sure that existing tests pass each time we run this file only
require Rails.root.join('test/functional/account_controller_test')

class AccountControllerTest
  fixtures :users, :roles

  context "GET /login CAS button" do
    should "show up only if there's a plugin setting for CAS URL" do
      Setting["plugin_redmine_omniauth_cas"]["cas_server"] = ""
      get :login
      assert_select '#cas-login', 0
      Setting["plugin_redmine_omniauth_cas"]["cas_server"] = "blah"
      get :login
      assert_select '#cas-login'
    end
  end

  context "GET login_with_cas_callback" do
    should "redirect to /my/page after successful login" do
      request.env["omniauth.auth"] = {"uid"=>"admin"}
      get :login_with_cas_callback, :provider => "cas"
      assert_redirected_to '/my/page'
    end

    should "redirect to /login after failed login" do
      request.env["omniauth.auth"] = {"uid"=>"non-existent"}
      get :login_with_cas_callback, :provider => "cas"
      assert_redirected_to '/login'
    end

    should "set a boolean in session to keep track of login" do
      request.env["omniauth.auth"] = {"uid"=>"admin"}
      get :login_with_cas_callback, :provider => "cas"
      assert_redirected_to '/my/page'
      assert session[:logged_in_with_cas]
    end

    should "redirect to Home if not logged in with CAS" do
      get :logout
      assert_redirected_to home_url
    end

    should "redirect to CAS logout if previously logged in with CAS" do
      session[:logged_in_with_cas] = true
      Setting["plugin_redmine_omniauth_cas"]["cas_server"] = "http://cas.server/"
      get :logout
      assert_redirected_to 'http://cas.server/logout?gateway=1&service=http://test.host/'
    end

    should "respect path in CAS server when generating logout url" do
      session[:logged_in_with_cas] = true
      Setting["plugin_redmine_omniauth_cas"]["cas_server"] = "http://cas.server/cas"
      get :logout
      assert_redirected_to 'http://cas.server/cas/logout?gateway=1&service=http://test.host/'
    end
  end
end
