class ChangePrimaryKeyToBigIntOnLineItems < ActiveRecord::Migration[5.0]
  def change
    remove_reference :submissions, :line_item, index: true, foreign_key: true
    change_column :line_items, :id, :bigint
    add_reference :submissions, :line_item, type: :bigint, index: true, foreign_key: true
  end
end
