class ChangePrimaryKeyToBigIntOnFulfillments < ActiveRecord::Migration[5.0]
  def change
    change_column :fulfillments, :id, :bigint
  end
end
