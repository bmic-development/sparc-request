class ChangePrimaryKeyToBigIntOnNotifications < ActiveRecord::Migration[5.0]
  def change
    change_column :notifications, :id, :bigint
  end
end
