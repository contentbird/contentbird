class AddGistIndexOnContentTitle < ActiveRecord::Migration
  def up
    execute "CREATE INDEX contents_title ON contents USING gin(to_tsvector('english', title));"
  end

  def down
    execute "DROP INDEX contents_title"
  end
end
