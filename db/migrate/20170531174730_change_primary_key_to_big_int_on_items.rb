class ChangePrimaryKeyToBigIntOnItems < ActiveRecord::Migration[5.0]
  def change
    remove_reference :item_options, :item, index: true, foreign_key: true
    remove_reference :questionnaire_responses, :item, index: true, foreign_key: true
    change_column :items, :id, :bigint
    add_reference :item_options, :item, type: :bigint, index: true, foreign_key: true
    add_reference :questionnaire_responses, :item, type: :bigint, index: true, foreign_key: true
  end
end
