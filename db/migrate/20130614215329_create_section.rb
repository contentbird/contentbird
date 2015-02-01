class CreateSection < ActiveRecord::Migration
  def change
    create_table :sections do |t|
      t.string  :label
      t.string  :title
      t.integer :position
      t.integer :channel_id
      t.integer :content_type_id
      t.string  :mode
      t.timestamps
    end
    add_index :sections, :position
    add_index :sections, :channel_id
    add_index :sections, :content_type_id
  end
end
