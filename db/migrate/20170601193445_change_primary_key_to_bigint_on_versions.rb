class ChangePrimaryKeyToBigintOnVersions < ActiveRecord::Migration[5.0]
  def change
    change_column :versions, :id, :bigint
  end
end
