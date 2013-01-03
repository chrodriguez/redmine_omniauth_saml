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
