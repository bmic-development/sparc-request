class ChangePrimaryKeyToBigintOnStudyTypeQuestionGroups < ActiveRecord::Migration[5.0]
  def change
    change_column :study_type_question_groups, :id, :bigint
  end
end
