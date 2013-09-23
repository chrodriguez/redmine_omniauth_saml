# Edit the options depending on your SAML needs
RedmineSAML = HashWithIndifferentAccess.new(
    :assertion_consumer_service_url => "http://localhost:3000", # The redmine application hostname
    :issuer                         => "saml-redmine",   # The issuer name
    :idp_sso_target_url             => "https://sso.server/SSOService", # SSO login endpoint
    :idp_cert_fingerprint           => "XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX", # SSL fingerprint
    :name_identifier_format         => "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress",
    :logout_admin                   => "https://sso.server/SingleLogoutService.php?ReturnTo=", # SSO logout URL
    :attribute_mapping              => { 
    # How will we map attributes from SSO to redmine attributes
      :login      => 'extra.raw_info.username',
      :firstname  => 'extra.raw_info.first_name',
      :lastname   => 'extra.raw_info.last_name',
      :mail       => 'extra.raw_info.personal_email'
    }
)

# The following code must be present. Don't remove it
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :saml, RedmineSAML
end
