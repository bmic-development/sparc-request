class ChangePrimaryKeyToBigIntOnLineItemsVisits < ActiveRecord::Migration[5.0]
  def change
    change_column :line_items_visits, :id, :bigint
  end
end
