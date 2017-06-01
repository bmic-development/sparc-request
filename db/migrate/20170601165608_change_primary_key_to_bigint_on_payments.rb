class ChangePrimaryKeyToBigintOnPayments < ActiveRecord::Migration[5.0]
  def change
    change_column :payments, :id, :bigint
  end
end
