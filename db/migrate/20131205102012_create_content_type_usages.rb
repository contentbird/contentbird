class CreateContentTypeUsages < ActiveRecord::Migration
  def up
    create_table :content_type_usages do |t|
      t.integer :user_id
      t.integer :content_type_id

      t.timestamps
    end

    CB::Core::User.all.each do |user|
      user.content_types << user.own_content_types
      user.save!
    end

    add_index :content_type_usages, [:user_id, :content_type_id], unique: true
  end

  def down
    remove_index :content_type_usages, [:user_id, :content_type_id]

    drop_table :content_type_usages
  end
end
