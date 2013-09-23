require_dependency 'account_helper'

module Redmine::OmniAuthSAML
  module AccountHelperPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        unloadable
      end
    end

    module InstanceMethods
      def label_for_saml_login
        Redmine::OmniAuthSAML.label_login_with_saml.presence || l(:label_login_with_saml)
      end
    end
  end
end

unless AccountHelper.included_modules.include? Redmine::OmniAuthSAML::AccountHelperPatch
  AccountHelper.send(:include, Redmine::OmniAuthSAML::AccountHelperPatch)
end
