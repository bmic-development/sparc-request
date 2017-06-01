class ChangePrimaryKeyToBigintOnQuestions < ActiveRecord::Migration[5.0]
  def change
    remove_reference :options, :question, index: true, foreign_key: true
    remove_reference :question_responses, :question, index: true, foreign_key: true
    change_column :questions, :id, :bigint
    add_reference :question_responses, :question, type: :bigint, index: true, foreign_key: true
    add_reference :options, :question, type: :bigint, index: true, foreign_key: true
  end
end
