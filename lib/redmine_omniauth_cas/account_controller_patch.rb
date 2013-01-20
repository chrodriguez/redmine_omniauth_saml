require_dependency 'account_controller'

module Redmine::OmniAuthCAS
  module AccountControllerPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        unloadable
        alias_method_chain :logout, :cas
      end
    end

    module InstanceMethods

      def login_with_cas_redirect
        render :text => "Not Found", :status => 404
      end

      def login_with_cas_callback
        auth = request.env["omniauth.auth"]
        #user = User.find_by_provider_and_uid(auth["provider"], auth["uid"])
        user = User.find_by_login(auth["uid"]) || User.find_by_mail(auth["uid"])

        # taken from original AccountController
        # maybe it should be splitted in core
        if user.blank?
          invalid_credentials
          error = l(:notice_account_invalid_creditentials).sub(/\.$/, '')
          if cas_settings[:cas_server].present?
            link = self.class.helpers.link_to(l(:text_logout_from_cas), cas_logout_url, :target => "_blank")
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
      def logout_with_cas
        if session[:logged_in_with_cas]
          #logout_user() erases session, so we cannot factor this before
          logout_user
          redirect_to cas_logout_url(home_url)
        else
          logout_without_cas
        end
      end

      private
      def cas_settings
        Redmine::OmniAuthCAS.settings_hash
      end

      def cas_logout_url(service = nil)
        logout_uri = URI.parse(cas_settings[:cas_server] + "/").merge("./logout")
        if !service.blank?
          logout_uri.query = "service=#{service}"
        end
        logout_uri.to_s
      end

    end
  end
end

unless AccountController.included_modules.include? Redmine::OmniAuthCAS::AccountControllerPatch
  AccountController.send(:include, Redmine::OmniAuthCAS::AccountControllerPatch)
end
