class CreatePublication < ActiveRecord::Migration
  def change
    create_table :publications do |t|
      t.integer  :channel_id
      t.integer  :content_id
      t.datetime :published_at
      t.timestamps
    end
    add_index :publications, :channel_id
    add_index :publications, :content_id
    add_index :publications, :published_at
  end
end
