class CreateContent < ActiveRecord::Migration
  def change
    create_table :contents do |t|
      t.string :title
      t.integer :owner_id
      t.integer :content_type_id
      t.text :properties
      t.timestamps
    end
    add_index :contents, :owner_id
    add_index :contents, :content_type_id
  end
end
