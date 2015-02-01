class AddPictoToContentTypes < ActiveRecord::Migration
  def change
    add_column :content_types, :picto, :string
  end
end
