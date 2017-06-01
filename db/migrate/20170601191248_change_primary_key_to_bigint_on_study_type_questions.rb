class ChangePrimaryKeyToBigintOnStudyTypeQuestions < ActiveRecord::Migration[5.0]
  def change
    change_column :study_type_questions, :id, :bigint
  end
end
