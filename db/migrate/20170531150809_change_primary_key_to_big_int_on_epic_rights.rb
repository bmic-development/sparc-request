class ChangePrimaryKeyToBigIntOnEpicRights < ActiveRecord::Migration[5.0]
  def change
    change_column :epic_rights, :id, :bigint
  end
end
