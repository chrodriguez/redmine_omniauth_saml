require_dependency 'user'

class User
  def self.find_or_create_from_omniauth(omniauth)
    user = self.find_by_login(saml_attribute(omniauth, :login))
    unless user
      if Redmine::OmniAuthSAML.onthefly_creation? 
        auth = {
          :firstname  => saml_attribute(omniauth, :firstname),
          :lastname   => saml_attribute(omniauth, :lastname),
          :mail       => saml_attribute(omniauth, :mail)
        }
        user = new(auth) 
        user.login    = saml_attribute(omniauth, :login)
        user.language = Setting.default_language
        user.activate
        user.save!
        user.reload
      end
    end
    user
  end

  private
    def self.saml_attribute(hash, symbol)
      h = HashWithIndifferentAccess.new hash
      key = RedmineSAML[:attribute_mapping][symbol]
      throw ArgumentError.new "There is no SAML attribute mapping for #{symbol}" unless key
      key.split('.')                        # Get an array with nested keys: name.first will return [name, first]
        .map {|x| [:[], x]}                 # Create pair elements being :[] symbol and the key
        .inject(h) do |hash, params|     # For each key, apply method :[] with key as parameter
          hash.send(*params)
        end
    end

end
