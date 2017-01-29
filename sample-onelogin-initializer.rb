
Redmine::OmniAuthSAML::Base.configure do |config|
  config.saml = {
#    :assertion_consumer_service_url => "http://yourcompany.redminegit.com/auth/saml/callback", # OmniAuth callback URL
    :assertion_consumer_service_url => "http://yourcompany.redminegit.com/auth/saml/consume", # OmniAuth callback URL
    :issuer                         => "https://app.onelogin.com/saml/metadata/123456",                    # The issuer name / entity ID. Must be an URI as per SAML 2.0 s$
    :idp_sso_target_url             => "https://acosonic.onelogin.com/trust/saml2/http-post/sso/123456", # SSO login endpoint
    :idp_cert_fingerprint           => "AA:AA:AA:AA:AA:E0:FB:E6:E0:38:BA:6A:6A:FA:DA:2D:03:05:2B:94", # SSO ssl certificate fingerprint
    # Alternatively, specify the full certifiate:
    #:idp_cert                       => "-----BEGIN CERTIFICATE-----\n...\n-----END CERTIFICATE-----",
    :name_identifier_format         => "urn:oasis:names:tc:SAML:2.0:nameid-format:persistent",
    :signout_url                    => "https://yourcomp.onelogin.com/trust/saml2/http-redirect/slo/123456", # Optional signout URL, not supported by all identity provide$
    :idp_slo_target_url             => "https://yourcomp.onelogin.com/trust/saml2/http-redirect/slo/123456",
    :name_identifier_value          => "mail", # Which redmine field is used as name_identifier_value for SAML logout
    :attribute_mapping              => {
    # How will we map attributes from SSO to redmine attributes
      :login      => 'extra.raw_info.username',
      :mail       => 'extra.raw_info.email',
      :firstname  => 'extra.raw_info.firstname',
      :lastname   => 'extra.raw_info.lastname'
    }
  }

  config.on_login do |omniauth_hash, user|
    # Implement any hook you want here
  end
end
