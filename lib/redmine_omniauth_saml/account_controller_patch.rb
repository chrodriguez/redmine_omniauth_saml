require_dependency 'account_controller'

module Redmine::OmniAuthSAML
  module AccountControllerPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        unloadable
        alias_method_chain :login, :saml
        alias_method_chain :logout, :saml
      end
    end

    module InstanceMethods

      def login_with_saml
        #TODO: test 'replace_redmine_login' feature
        if saml_settings["enabled"] && saml_settings["replace_redmine_login"]
          redirect_to :controller => "account", :action => "login_with_saml_redirect", :provider => "saml", :origin => back_url
        else
          login_without_saml
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

      def logout_with_saml
        if saml_settings["enabled"] && session[:logged_in_with_saml]
          logout_user
          redirect_to saml_logout_url(home_url)
        else
          logout_without_saml
        end
      end

      private
      def saml_settings
        Redmine::OmniAuthSAML.settings_hash
      end

      def saml_logout_url(service = nil)
        logout_uri = RedmineSAML['logout_admin']
        logout_uri += service.to_s unless logout_uri.blank?
        logout_uri || home_url
      end

    end
  end
end

unless AccountController.included_modules.include? Redmine::OmniAuthSAML::AccountControllerPatch
  AccountController.send(:include, Redmine::OmniAuthSAML::AccountControllerPatch)
  AccountController.skip_before_filter :verify_authenticity_token, :only => [:login_with_saml_callback]
end
