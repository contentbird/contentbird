class AddProviderRefToPublications < ActiveRecord::Migration
  def change
    add_column :publications, :provider_ref, :string
  end
end
