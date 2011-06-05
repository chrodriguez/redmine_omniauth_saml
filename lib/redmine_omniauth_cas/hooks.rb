module RedmineOmniauth
  class Hooks < Redmine::Hook::ViewListener
    render_on :view_account_login_top, :partial => 'redmine_omniauth_cas/view_account_login_top'
  end
end
