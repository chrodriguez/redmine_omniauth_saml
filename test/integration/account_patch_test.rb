require File.expand_path('../../test_helper', __FILE__)

class AccountPatchTest < ActionController::IntegrationTest
  fixtures :users, :roles

  context "GET /auth/:provider" do
    should "route to a blank action (intercepted by omniauth middleware)" do
      assert_routing(
        { :method => :get, :path => "/auth/blah" },
        { :controller => 'account', :action => 'login_with_cas_redirect', :provider => 'blah' }
      )
    end
    #TODO: some real test?
  end
  context "GET /auth/:provider/callback" do
    should "route things correctly" do
      assert_routing(
        { :method => :get, :path => "/auth/blah/callback" },
        { :controller => 'account', :action => 'login_with_cas_callback', :provider => 'blah' }
      )
    end

    context "OmniAuth CAS strategy" do
      setup do
        Setting.default_language = 'en'
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

      should "update last_login_on field" do
        user = User.find(1)
        user.update_attribute(:last_login_on, Time.now - 6.hours)
        OmniAuth.config.mock_auth[:cas] = { 'uid' => 'admin' }
        get '/auth/cas/callback'
        assert_redirected_to '/my/page'
        assert Time.now - User.current.last_login_on < 30.seconds
      end

      should "refuse login if user doesn't exist" do
        OmniAuth.config.mock_auth[:cas] = { 'uid' => 'johndoe' }
        get '/auth/cas/callback'
        assert_redirected_to '/login'
        follow_redirect!
        assert_equal User.anonymous, User.current
        assert_select 'div.flash.error', /Invalid user or password/
      end
    end
  end
end
