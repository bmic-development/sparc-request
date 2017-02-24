class RemoveOrgAttributesFromIdentities < ActiveRecord::Migration
  def change
    remove_column :identities, :institution
    remove_column :identities, :college
    remove_column :identities, :department
  end
end
