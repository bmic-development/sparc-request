class ChangePrimaryKeyToBigIntOnAdminRates < ActiveRecord::Migration[5.0]
  def change
    change_column :admin_rates, :id, :bigint
  end
end
