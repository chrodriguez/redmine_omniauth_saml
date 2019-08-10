require_dependency 'account_controller'

module Redmine::OmniAuthSAML
  module AccountControllerPatch
    def self.included(base)
      base.class_eval do
        unloadable
        AccountController.prepend(AccountControllerPatch)
      end
    end

    def login
      #TODO: test 'replace_redmine_login' feature
      if saml_settings["enabled"] && saml_settings["replace_redmine_login"]
        redirect_to :controller => "account", :action => "login_with_saml_redirect", :provider => "saml", :origin => back_url
      else
        super
      end
    end

    def login_with_saml_redirect
      render :text => "Not Found", :status => 404
    end

    def login_with_saml_callback
      auth = request.env["omniauth.auth"]
      #user = User.find_by_provider_and_uid(auth["provider"], auth["uid"])
      user = User.find_or_create_from_omniauth(auth) 

      # taken from original AccountController
      # maybe it should be splitted in core
      if user.blank?
        logger.warn "Failed login for '#{auth[:uid]}' from #{request.remote_ip} at #{Time.now.utc}"
        error = l(:notice_account_invalid_creditentials).sub(/\.$/, '')
        if saml_settings["enabled"]
          link = self.class.helpers.link_to(l(:text_logout_from_saml), saml_logout_url(home_url), :target => "_blank")
          error << ". #{l(:text_full_logout_proposal, :value => link)}"
        end
        if saml_settings["replace_redmine_login"]
          render_error({:message => error.html_safe, :status => 403})
          return false
        else
          flash[:error] = error
          redirect_to signin_url
        end
      else
        user.update_attribute(:last_login_on, Time.now)
        params[:back_url] = request.env["omniauth.origin"] unless request.env["omniauth.origin"].blank?
        successful_authentication(user)
        #cannot be set earlier, because sucessful_authentication() triggers reset_session()
        session[:logged_in_with_saml] = true
      end
    end

    def login_with_saml_failure
      error = params[:message] || 'unknown'
      error = 'error_saml_' + error
      if saml_settings["replace_redmine_login"]
        render_error({:message => error.to_sym, :status => 500})
        return false
      else
        flash[:error] = l(error.to_sym)
        redirect_to signin_url
      end
    end

    def logout
      if saml_settings["enabled"] && session[:logged_in_with_saml]
        do_logout_with_saml
      else
        super
      end
    end

    def do_logout_with_saml
      # If we're given a logout request, handle it in the IdP logout initiated method
      if params[:SAMLRequest]
        idp_logout_request
      # We've been given a response back from the IdP, process it
      elsif params[:SAMLResponse]
        process_logout_response
      # Initiate SLO (send Logout Request)
      else
        sp_logout_request
      end
    end

    # Method to handle IdP initiated logouts
    def idp_logout_request
      settings = OneLogin::RubySaml::Settings.new omniauth_saml_settings
      logout_request = OneLogin::RubySaml::SloLogoutrequest.new(params[:SAMLRequest])
      unless logout_request.is_valid?
        logger.error 'IdP initiated LogoutRequest was not valid!'
        render :inline => logger.error
        return
      end
      logger.info "IdP initiated Logout for #{logout_request.name_id}"

      # Actually log out this session
      saml_logout_user

      # Generate a response to the IdP.
      logout_request_id = logout_request.id
      logout_response = OneLogin::RubySaml::SloLogoutresponse.new.create(settings, logout_request_id, nil, :RelayState => params[:RelayState])

      redirect_to logout_response
    end

    # After sending an SP initiated LogoutRequest to the IdP, we need to accept
    # the LogoutResponse, verify it, then actually delete our session.
    def process_logout_response
      settings = OneLogin::RubySaml::Settings.new omniauth_saml_settings

      logout_response = OneLogin::RubySaml::Logoutresponse.new(params[:SAMLResponse], settings, session.has_key?(:transaction_id) ? { matches_request_id: session[:transaction_id] } : {})

      logger.info "LogoutResponse is: #{logout_response.to_s}"

      # Validate the SAML Logout Response
      if not logout_response.validate
        logger.error "The SAML Logout Response is invalid"
      else
        # Actually log out this session
        if logout_response.success?
          logger.info "Delete session for '#{User.current.login}'"
          saml_logout_user
        end
      end

      redirect_to home_path
    end

    # Create a SP initiated SLO
    def sp_logout_request
      # LogoutRequest accepts plain browser requests w/o parameters
      settings = omniauth_saml_settings

      if not settings[:signout_url]
        logger.info "SLO IdP Endpoint not found in settings, executing then a normal logout'"
        saml_logout_user
        redirect_to home_path
      else

        # Since we created a new SAML request, save the transaction_id
        # to compare it with the response we get back
        logout_request = OneLogin::RubySaml::Logoutrequest.new
        session[:transaction_id] = logout_request.uuid
        logger.info "New SP SLO for userid '#{User.current.login}' transactionid '#{session[:transaction_id]}'"

        settings[:name_identifier_value] ||= name_identifier_value

        relay_state = home_url # url_for controller: 'saml', action: 'index'
        redirect_to(logout_request.create(OneLogin::RubySaml::Settings.new(settings), :RelayState => relay_state))
      end
    end

    # Manage SLS response
    def redirect_after_saml_logout
      saml_logout_user
      redirect_to signin_url
    end

    private
    def saml_logout_user
      logout_user
      reset_session
    end

    def name_identifier_value
      User.current.send Redmine::OmniAuthSAML.configured_saml[:name_identifier_value].to_sym
    end

    def saml_settings
      Redmine::OmniAuthSAML.settings_hash
    end

    def omniauth_saml_settings
      Redmine::OmniAuthSAML.configured_saml
    end

    def saml_logout_url(service = nil)
      logout_uri = Redmine::OmniAuthSAML.configured_saml[:signout_url]
      logout_uri += service.to_s unless logout_uri.blank?
      logout_uri || home_url
    end

  end
end

unless AccountController.included_modules.include? Redmine::OmniAuthSAML::AccountControllerPatch
  AccountController.prepend(Redmine::OmniAuthSAML::AccountControllerPatch)
  AccountController.before_action :verify_authenticity_token, :except => [:login_with_saml_callback]
end
