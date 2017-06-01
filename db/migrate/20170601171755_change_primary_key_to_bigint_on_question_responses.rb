class ChangePrimaryKeyToBigintOnQuestionResponses < ActiveRecord::Migration[5.0]
  def change
    change_column :question_responses, :id, :bigint
  end
end
