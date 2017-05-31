class ChangePrimaryKeyToBigIntOnApprovals < ActiveRecord::Migration[5.0]
  def change
    change_column :approvals, :id, :bigint
  end
end
