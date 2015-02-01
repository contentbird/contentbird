class AddUnpublishErrorsFieldsToPublications < ActiveRecord::Migration
  def change
    add_column :publications, :last_failed_unpublish_at, :datetime
    add_column :publications, :last_failed_unpublish_message, :string
    add_column :publications, :failed_unpublish_count, :integer, default: 0
  end
end
