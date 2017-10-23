Redmine::OmniAuthSAML::Base.configure do |config|
  config.saml = {
    :assertion_consumer_service_url => "http://redmine.example.com/auth/saml/callback", # OmniAuth callback URL
    :issuer                         => "http://redmine.example.com/saml/metadata",      # The issuer name / entity ID. Must be an URI as per SAML 2.0 spec.
    :single_logout_service_url      => "http://redmine.example.com/auth/saml/sls",      # The SLS (logout) callback URL
    :idp_sso_target_url             => "http://sso.desarrollo.unlp.edu.ar/saml2/idp/SSOService.php", # SSO login endpoint
    :idp_cert_fingerprint           => "certificate fingerprint", # SSO ssl certificate fingerprint
    # Alternatively, specify the full certifiate:
    #:idp_cert                       => "-----BEGIN CERTIFICATE-----\n...\n-----END CERTIFICATE-----",
    :name_identifier_format         => "urn:oasis:names:tc:SAML:2.0:nameid-format:persistent",
    :signout_url                    => "http://sso.example.com/saml2/idp/SingleLogoutService.php?ReturnTo=", # Optional signout URL, not supported by all identity providers
    :idp_slo_target_url             => "http://sso.example.com/saml2/idp/SingleLogoutService.php",
    :name_identifier_value          => "mail", # Which redmine field is used as name_identifier_value for SAML logout
    :attribute_mapping              => {
    # How will we map attributes from SSO to redmine attributes
      :login      => 'extra.raw_info.username',
      :mail       => 'extra.raw_info.email',
      :firstname  => 'extra.raw_info.firstname',
      :lastname   => 'extra.raw_info.firstname'
    }
  }

  config.on_login do |omniauth_hash, user|
    # Implement any hook you want here
  end
end
