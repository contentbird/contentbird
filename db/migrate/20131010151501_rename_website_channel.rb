class RenameWebsiteChannel < ActiveRecord::Migration
  def up
    change_column(:channels, :type, :string, default: 'CB::Core::WebsiteChannel')
    execute("UPDATE channels SET type = 'CB::Core::WebsiteChannel' WHERE type = 'CB::Core::WebSiteChannel'")
  end
  def down
    execute("UPDATE channels SET type = 'CB::Core::WebSiteChannel' WHERE type = 'CB::Core::WebsiteChannel'")
    change_column(:channels, :type, :string, default: 'CB::Core::WebSiteChannel')
  end
end
