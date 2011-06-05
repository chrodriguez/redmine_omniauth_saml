require File.expand_path('../../test_helper', __FILE__)

class AccountPatchTest < ActionController::IntegrationTest
  fixtures :users, :roles

  context "GET /auth/:provider/callback" do
    should_route :get, "/auth/blah/callback", :controller => 'account',
                                              :action => 'login_with_omniauth',
                                              :provider => 'blah'

    context "OmniAuth CAS strategy" do
      setup do
        OmniAuth.config.test_mode = true
      end

      should "authorize login if user exists with this login" do
        OmniAuth.config.mock_auth[:cas] = { 'uid' => 'admin' }
        get '/auth/cas/callback'
        assert_redirected_to '/my/page'
        assert_equal "admin", User.current.login
      end

      should "authorize login if user exists with this email" do
        OmniAuth.config.mock_auth[:cas] = { 'uid' => 'admin@somenet.foo' }
        get '/auth/cas/callback'
        assert_redirected_to '/my/page'
        assert_equal "admin", User.current.login
      end

      should "refuse login if user doesn't exist" do
        OmniAuth.config.mock_auth[:cas] = { 'uid' => 'johndoe' }
        get '/auth/cas/callback'
        assert_redirected_to '/login'
        assert_equal User.anonymous, User.current
      end
    end
  end
end
