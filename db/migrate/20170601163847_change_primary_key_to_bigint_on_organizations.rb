class ChangePrimaryKeyToBigintOnOrganizations < ActiveRecord::Migration[5.0]
  def change
    change_column :organizations, :id, :bigint
  end
end
