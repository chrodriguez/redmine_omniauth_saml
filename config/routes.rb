RedmineApp::Application.routes.draw do
  match '/auth/failure'             => 'account#login_with_saml_failure',   via: [:get, :post]
  match '/auth/:provider/callback'  => 'account#login_with_saml_callback',  via: [:get, :post]
  match '/auth/:provider'           => 'account#login_with_saml_redirect',  as: :sign_in, via: [:get, :post]
end
