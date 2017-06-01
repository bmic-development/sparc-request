class ChangePrimaryKeyToBigintOnQuestionnaireResponses < ActiveRecord::Migration[5.0]
  def change
    change_column :questionnaire_responses, :id, :bigint
  end
end
