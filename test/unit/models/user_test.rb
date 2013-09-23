require File.expand_path('../../../test_helper', __FILE__)

class UserPatchTest < ActiveSupport::TestCase
  setup do
    Setting['plugin_redmine_omniauth_saml']['enabled'] = true
    RedmineSAML[:attribute_mapping] = {
        'login'      => 'login',
        'firstname'  => 'first_name',
        'lastname'   => 'last_name',
        'mail'       => 'mail'
      }

  end

  context "User#find_or_create_from_omniauth" do
    should "find created user" do
      u = User.new(
        :firstname => 'name',
        :lastname => 'last',
        :mail => 'mail@example.net')
      u.login = 'login'
      assert u.save
      assert_not_nil User.find_or_create_from_omniauth(:login => 'login')
    end

    context "onthefly_creation? disabled" do
      setup do
        Setting['plugin_redmine_omniauth_saml']['onthefly_creation'] = false
      end

      should "return nil when user not exists" do
        assert_nil User.find_or_create_from_omniauth(:login => 'not_existent')
      end
    end

    context "onthefly_creatio? enabled" do
      setup do
        Setting['plugin_redmine_omniauth_saml']['onthefly_creation'] = true
      end

      should "return created user" do
        new = User.find_or_create_from_omniauth(:login => 'new', :first_name => 'first name', :last_name => 'last name', :mail => 'new@example.com')
        assert_not_nil new
        assert_in_delta Time.now, new.created_on, 1
      end
    end

    context "different attribute mappings" do
      setup do
        Setting['plugin_redmine_omniauth_saml']['onthefly_creation'] = true
      end

      should "map single level attribute" do
        attributes = { :login => 'new', :first_name => 'first name', :last_name => 'last name', :mail => 'new@example.com' }
        new = User.find_or_create_from_omniauth attributes
        assert_not_nil new
        assert_equal attributes[:login], new.login
        assert_equal attributes[:first_name], new.firstname
        assert_equal attributes[:last_name], new.lastname
        assert_equal attributes[:mail], new.mail
      end

      should "map nested levels attributes" do
        RedmineSAML[:attribute_mapping] = {
            :login      => 'one.two.three.four.levels.username',
            :firstname  => 'one.two.three.four.levels.first_name',
            :lastname   => 'one.two.three.four.levels.last_name',
            :mail       => 'one.two.three.four.levels.personal_email'
          }

        real_att = { 
          'username'       => 'new',
          'first_name'  => 'first name',
          'last_name' => 'last name',
          'personal_email'     => 'mail@example.com'
        }

        attributes = { 'one' => { 'two' => { 'three' => { 'four' => { 'levels' =>  real_att }}}}}

        new = User.find_or_create_from_omniauth attributes

        assert_not_nil new

        assert_equal real_att['username'], new.login
        assert_equal real_att['first_name'], new.firstname
        assert_equal real_att['last_name'], new.lastname
        assert_equal real_att['personal_email'], new.mail

      end
    end
  end
end
