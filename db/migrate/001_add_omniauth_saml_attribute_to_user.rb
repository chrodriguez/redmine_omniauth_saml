class AddOmniauthSamlAttributeToUser < ActiveRecord::Migration
  def change
    add_column :users, :created_by_omniauth_saml, :boolean, default: false
  end
end
