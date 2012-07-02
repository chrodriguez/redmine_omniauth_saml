RedmineApp::Application.routes.draw do
  match 'auth/:provider/callback', :to => 'account#login_with_omniauth'
  match 'auth/:provider', :to => 'account#blank'
end
