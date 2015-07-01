Redmine::OmniAuthSAML::Base.configure do |config|
  config.saml = {
    :assertion_consumer_service_url => "http://redmine.example.com", # The redmine application hostname
    :issuer                         => "sso_issuer",                 # The issuer name
    :idp_sso_target_url             => "http://sso.desarrollo.unlp.edu.ar/saml2/idp/SSOService.php", # SSO login endpoint
    :idp_cert_fingerprint           => "certificate fingerprint", # SSO ssl certificate fingerprint
    :name_identifier_format         => "urn:oasis:names:tc:SAML:2.0:nameid-format:persistent",
    :signout_url                    => "http://sso.example.com/saml2/idp/SingleLogoutService.php?ReturnTo=",
    :idp_slo_target_url             => "http://sso.example.com/saml2/idp/SingleLogoutService.php",
    :name_identifier_value          => "mail", # Which redmine field is used as name_identifier_value for SAML logout
    :attribute_mapping              => {
    # How will we map attributes from SSO to redmine attributes
      :login      => 'extra.raw_info.username',
      :firstname  => 'extra.raw_info.first_name',
      :lastname   => 'extra.raw_info.last_name',
      :mail       => 'extra.raw_info.email'
    }
  }

  config.on_login do |omniauth_hash, user|
    # Implement any hook you want here
  end
end
