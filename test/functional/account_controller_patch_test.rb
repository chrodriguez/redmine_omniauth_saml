require File.expand_path('../../test_helper', __FILE__)

#let's use the existing functional test so we don't have to re-setup everything
#+ we are sure that existing tests pass each time we run this file only
require 'test/functional/account_controller_test'

class AccountControllerTest
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
end
