RedmineApp::Application.routes.draw do
  match 'auth/:provider/callback', :to => 'account#login_with_cas_callback'
  match 'auth/:provider', :to => 'account#login_with_cas_redirect'
end
