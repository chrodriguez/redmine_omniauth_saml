module Redmine::OmniAuthSAML
  class << self

    def settings_hash
      Setting["plugin_redmine_omniauth_saml"]
    end

    def enabled?
      settings_hash["enabled"]
    end

    def onthefly_creation?
      enabled? && settings_hash["onthefly_creation"]
    end

    def label_login_with_saml
      settings_hash["label_login_with_saml"]
    end

    def user_attributes_from_saml(omniauth)
      Base.user_attributes_from_saml omniauth
    end

    def configured_saml
      Base.configured_saml
    end

    def on_login_callback
      Base.on_login_callback
    end

  end

  class Base
    class << self
      def saml
        @@saml
      end

      def on_login(&block)
        @@block = block
      end

      def on_login_callback
        @@block ||= nil
      end

      def saml=(val)
        @@saml = HashWithIndifferentAccess.new(val)
      end

      def configured_saml
        raise_configure_exception unless validated_configuration
        saml
      end

      def configure(&block)
        raise_configure_exception if block.nil?
        yield self
        validate_configuration!
      end

      def user_attributes_from_saml(omniauth)
        HashWithIndifferentAccess.new.tap do |h|
          required_attribute_mapping.each do |symbol|
            key = configured_saml[:attribute_mapping][symbol]
            h[symbol] = key.split('.')                # Get an array with nested keys: name.first will return [name, first]
              .map {|x| [:[], x]}                     # Create pair elements being :[] symbol and the key
              .inject(omniauth) do |hash, params|     # For each key, apply method :[] with key as parameter
                hash.send(*params)
              end
          end
        end
      end

      private

      def validated_configuration
        @@validated_configuration ||= false
      end

      def required_attribute_mapping
        [ :login,
          :firstname,
          :lastname,
          :mail ]
      end

      def validate_configuration!
        [ :assertion_consumer_service_url,
          :issuer,
          :idp_sso_target_url,
          :name_identifier_format,
          :idp_slo_target_url,
          :name_identifier_value,
          :attribute_mapping ].each do |k|
            raise "Redmine::OmiauthSAML.configure requires saml.#{k} to be set" unless saml[k]
          end

        raise "Redmine::OmiauthSAML.configure requires either saml.idp_cert_fingerprint or saml.idp_cert to be set" unless saml[:idp_cert_fingerprint] || saml[:idp_cert]

        required_attribute_mapping.each do |k|
          raise "Redmine::OmiauthSAML.configure requires saml.attribute_mapping[#{k}] to be set" unless saml[:attribute_mapping][k]
        end

        raise 'Redmine::OmiauthSAML on_login must be a Proc only' if on_login_callback && !on_login_callback.is_a?(Proc)

        @@validated_configuration = true

        configure_omniauth_saml_middleware
      end

      def raise_configure_exception
        raise 'Redmine::OmniAuthSAML must be configured from an initializer. See README of redmine_omniauth_saml for instructions'
      end

      def configure_omniauth_saml_middleware
        saml_options = configured_saml
        Rails.application.config.middleware.use ::OmniAuth::Builder do
            provider :saml, saml_options
        end
      end
    end
  end
end
