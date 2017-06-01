class ChangePrimaryKeyToBigintOnResponses < ActiveRecord::Migration[5.0]
  def change
    remove_reference :question_responses, :response, index: true, foreign_key: true
    change_column :responses, :id, :bigint
    add_reference :question_responses, :response, type: :bigint, index: true, foreign_key: true
  end
end
