class AddLastAnnouncementClickedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :last_announcement_clicked, :string
  end
end
