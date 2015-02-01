class AddExpireAtToPublications < ActiveRecord::Migration
  def change
    add_column :publications, :expire_at, :datetime
  end
end
