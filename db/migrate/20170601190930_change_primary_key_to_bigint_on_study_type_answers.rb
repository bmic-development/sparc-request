class ChangePrimaryKeyToBigintOnStudyTypeAnswers < ActiveRecord::Migration[5.0]
  def change
    change_column :study_type_answers, :id, :bigint
  end
end
