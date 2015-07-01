require_dependency 'user'

class User
  def self.find_or_create_from_omniauth(omniauth)
    user_attributes = Redmine::OmniAuthSAML.user_attributes_from_saml omniauth
    user = self.find_by_login(user_attributes[:login])
    unless user
      if Redmine::OmniAuthSAML.onthefly_creation? 
        user = new user_attributes
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

end
