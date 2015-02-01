class AddFirstImageFieldsToContents < ActiveRecord::Migration
  def change
    add_column :contents, :first_image_property_key, :string
    add_column :contents, :first_image_property_url, :string
  end
end
