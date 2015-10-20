require_dependency 'user'

class User


  def self.find_or_create_from_omniauth(omniauth)
    user_attributes = Redmine::OmniAuthSAML.user_attributes_from_saml omniauth
    user = self.find_by_login(user_attributes[:login])
    unless user
      user = EmailAddress.find_by(address: user_attributes[:mail]).try(:user)
      if user.nil? && Redmine::OmniAuthSAML.onthefly_creation? 
        user = new user_attributes
        user.created_by_omniauth_saml = true
        user.login    = user_attributes[:login]
        user.language = Setting.default_language
        user.activate
        user.save!
        user.reload
      end
    end
    Redmine::OmniAuthSAML.on_login_callback.call(omniauth, user) if Redmine::OmniAuthSAML.on_login_callback
    user
  end

  def change_password_allowed_with_omniauth_saml?
    change_password_allowed_without_omniauth_saml? && !created_by_omniauth_saml?
  end

  alias_method_chain :change_password_allowed?, :omniauth_saml

end
