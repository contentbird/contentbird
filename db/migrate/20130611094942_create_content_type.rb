class CreateContentType < ActiveRecord::Migration
  def change
    create_table :content_types do |t|
      t.string :name
      t.timestamps
    end
    add_index :content_types, :name
  end
end
