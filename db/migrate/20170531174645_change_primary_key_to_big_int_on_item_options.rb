class ChangePrimaryKeyToBigIntOnItemOptions < ActiveRecord::Migration[5.0]
  def change
    change_column :item_options, :id, :bigint
  end
end
