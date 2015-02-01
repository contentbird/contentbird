class AddAllowSocialFeedToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :allow_social_feed, :boolean, default: false
  end
end
