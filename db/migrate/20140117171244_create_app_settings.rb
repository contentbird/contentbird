class CreateAppSettings < ActiveRecord::Migration
  def change
    create_table :app_settings do |t|
      t.string :key, limit: 50
      t.string :value

      t.timestamps
    end
    add_index :app_settings, :key
  end
end
