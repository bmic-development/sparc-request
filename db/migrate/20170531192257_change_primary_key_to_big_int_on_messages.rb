class ChangePrimaryKeyToBigIntOnMessages < ActiveRecord::Migration[5.0]
  def change
    change_column :messages, :id, :bigint
  end
end
