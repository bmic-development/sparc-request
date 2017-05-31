class ChangePrimaryKeyToBigIntOnLookups < ActiveRecord::Migration[5.0]
  def change
    change_column :lookups, :id, :bigint
  end
end
