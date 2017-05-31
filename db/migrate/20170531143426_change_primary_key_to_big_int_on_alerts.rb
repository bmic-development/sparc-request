class ChangePrimaryKeyToBigIntOnAlerts < ActiveRecord::Migration[5.0]
  def change
    change_column :alerts, :id, :bigint
  end
end
