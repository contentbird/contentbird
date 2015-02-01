class CreateChannelSubscriptions < ActiveRecord::Migration
  def change
    create_table :channel_subscriptions do |t|
      t.integer :contact_id
      t.integer :channel_id

      t.timestamps
    end

    add_index :channel_subscriptions, [:contact_id, :channel_id], unique: true
  end
end
