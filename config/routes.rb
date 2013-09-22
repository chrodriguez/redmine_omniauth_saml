RedmineApp::Application.routes.draw do
  match 'auth/failure', :to => 'account#login_with_saml_failure'
  match 'auth/:provider/callback', :to => 'account#login_with_saml_callback'
  match 'auth/:provider', :to => 'account#login_with_saml_redirect'
end
