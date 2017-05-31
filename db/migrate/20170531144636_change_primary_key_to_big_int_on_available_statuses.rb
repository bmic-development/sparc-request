class ChangePrimaryKeyToBigIntOnAvailableStatuses < ActiveRecord::Migration[5.0]
  def change
    change_column :available_statuses, :id, :bigint
  end
end
