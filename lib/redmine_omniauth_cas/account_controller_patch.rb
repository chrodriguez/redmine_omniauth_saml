require_dependency 'account_controller'

class AccountController
  def login_with_omniauth
    auth = request.env["omniauth.auth"]
    #user = User.find_by_provider_and_uid(auth["provider"], auth["uid"])
    user = User.find_by_login(auth["uid"]) || User.find_by_mail(auth["uid"])

    # taken from original AccountController
    # maybe it should be splitted in core
    if user.blank?
      invalid_credentials
      redirect_to signin_url
    else
      successful_authentication(user)
    end
  end
end
