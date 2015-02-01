class AddForewordsToSections < ActiveRecord::Migration
  def change
    add_column :sections, :forewords, :text
  end
end
