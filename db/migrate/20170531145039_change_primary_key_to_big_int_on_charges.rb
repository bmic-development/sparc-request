class ChangePrimaryKeyToBigIntOnCharges < ActiveRecord::Migration[5.0]
  def change
    change_column :charges, :id, :bigint
  end
end
