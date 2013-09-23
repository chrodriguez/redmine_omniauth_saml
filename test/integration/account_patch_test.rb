require File.expand_path('../../test_helper', __FILE__)

class AccountPatchTest < ActionController::IntegrationTest
  fixtures :users, :roles

  context "GET /auth/:provider" do
    should "route to a blank action (intercepted by omniauth middleware)" do
      assert_routing(
        { :method => :get, :path => "/auth/blah" },
        { :controller => 'account', :action => 'login_with_saml_redirect', :provider => 'blah' }
      )
    end
    #TODO: some real test?
  end
  context "GET /auth/:provider/callback" do
    should "route things correctly" do
      assert_routing(
        { :method => :get, :path => "/auth/blah/callback" },
        { :controller => 'account', :action => 'login_with_saml_callback', :provider => 'blah' }
      )
    end

    context "OmniAuth SAML strategy" do
      setup do
        Setting.default_language = 'en'
        Setting["plugin_redmine_omniauth_saml"]["enabled"] = true
        Setting['plugin_redmine_omniauth_saml']['onthefly_creation']= false
        OmniAuth.config.test_mode = true
        RedmineSAML[:attribute_mapping] = {
          'login'      => 'login',
          'firstname'  => 'first_name',
          'lastname'   => 'last_name',
          'mail'       => 'mail'
        }
      end

      should "authorize login if user exists with this login" do
        OmniAuth.config.mock_auth[:saml] = { 'login' => 'admin' }
        get '/auth/saml/callback'
        assert_redirected_to '/my/page'
        assert_equal "admin", User.current.login
      end

      should "update last_login_on field" do
        user = User.find(1)
        user.update_attribute(:last_login_on, Time.now - 6.hours)
        OmniAuth.config.mock_auth[:saml] = { 'login' => 'admin' }
        get '/auth/saml/callback'
        assert_redirected_to '/my/page'
        assert Time.now - User.current.last_login_on < 30.seconds
      end

      should "refuse login if user doesn't exist" do
        OmniAuth.config.mock_auth[:saml] = { 'login' => 'johndoe' }
        get '/auth/saml/callback'
        assert_redirected_to '/login'
        follow_redirect!
        assert_equal User.anonymous, User.current
        assert_select 'div.flash.error', /Invalid user or password/
      end

      should "create user if doesn't exist when on thefly_creation is set" do
        Setting['plugin_redmine_omniauth_saml']['onthefly_creation']= true

        OmniAuth.config.mock_auth[:saml] = { 'login' => 'johndoe', 'first_name' => 'first name', 'last_name' => 'last name', 'mail' => 'mail@example.com' }
        get '/auth/saml/callback'
        assert_redirected_to '/my/page'
        follow_redirect!
        assert_equal "johndoe", User.current.login
        assert Time.now - User.current.last_login_on < 30.seconds
        assert Time.now - User.current.created_on < 30.seconds
      end
    end
  end
end
