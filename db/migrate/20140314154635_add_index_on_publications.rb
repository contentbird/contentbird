class AddIndexOnPublications < ActiveRecord::Migration
  def change
    add_index :publications, [:deleted_at, :expire_at, :failed_unpublish_count], name: 'index_publications_on_del_expire_failed_unpublish'
  end
end
