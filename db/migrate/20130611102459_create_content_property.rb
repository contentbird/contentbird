class CreateContentProperty < ActiveRecord::Migration
  def change
    create_table :content_properties do |t|
      t.string  :name
      t.integer :position
      t.integer :father_type_id
      t.integer :content_type_id
      t.timestamps
    end
    add_index :content_properties, :content_type_id
    add_index :content_properties, [:father_type_id, :position]
  end
end
