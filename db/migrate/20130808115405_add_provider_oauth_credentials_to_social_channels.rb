class AddProviderOauthCredentialsToSocialChannels < ActiveRecord::Migration
  def change
    add_column :channels, :provider_oauth_token,  :string
    add_column :channels, :provider_oauth_secret, :string
  end
end
