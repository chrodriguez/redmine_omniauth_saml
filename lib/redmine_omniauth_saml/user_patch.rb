require_dependency 'user'

module OmniAuthSamlUser
  def self.prepended(base)
    class << base
      self.prepend(OmniAuthSamlUserMethods)
    end
  end

  module OmniAuthSamlUserMethods
    def find_or_create_from_omniauth(omniauth)
      user_attributes = Redmine::OmniAuthSAML.user_attributes_from_saml omniauth

      user = nil
      unless user_attributes[:login].nil? or user_attributes[:login].empty?
        user = self.find_by_login(user_attributes[:login])
      end
      if user.nil?
        user = EmailAddress.find_by(address: user_attributes[:mail]).try(:user)
      end
      if user.nil? && Redmine::OmniAuthSAML.onthefly_creation?
        user = new user_attributes
        user.created_by_omniauth_saml = true
        if user_attributes[:login].nil? or user_attributes[:login].empty?
          user.login = user_attributes[:mail]
        else
          user.login = user_attributes[:login]
        end

        user.language = Setting.default_language
        user.activate
        user.save!
        user.reload
      end
      unless user.nil?
        user.firstname = user_attributes[:firstname]
        user.lastname = user_attributes[:lastname]
        user.admin = (!user_attributes[:admin].nil? and !user_attributes[:admin].empty? and user_attributes[:admin])
        Redmine::OmniAuthSAML.on_login_callback.call(omniauth, user) if Redmine::OmniAuthSAML.on_login_callback
      end
      user
    end
  end


  def change_password_allowed?
    super && !created_by_omniauth_saml?
  end

end

User.prepend(OmniAuthSamlUser)
