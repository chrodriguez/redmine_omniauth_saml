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
      error = l(:notice_account_invalid_creditentials)
      if cas_url.present?
        link = self.class.helpers.link_to(l(:text_logout_from_cas), cas_url+"/logout", :target => "_blank")
        error << ". #{l(:text_full_logout_proposal, :value => link)}"
      end
      flash[:error] = error
      redirect_to signin_url
    else
      user.update_attribute(:last_login_on, Time.now)
      successful_authentication(user)
      #cannot be set earlier, because sucessful_authentication() triggers reset_session()
      session[:logged_in_with_cas] = true
    end
  end

  # Override AccountController#logout so we handle CAS logout too
  def logout
    if session[:logged_in_with_cas]
      #logout_user() erases session, so we cannot factor this before
      logout_user
      cas_logout_url = URI.parse(Redmine::OmniAuthCAS.cas_server)
                          .merge("/logout?gateway=1&service=#{home_url}")
                          .to_s
      redirect_to cas_logout_url
    else
      logout_user
      redirect_to home_url
    end
  end

  def blank
    render :text => "Not Found", :status => 404
  end

  private
  def cas_url
    Redmine::OmniAuthCAS.cas_server
  end
end
