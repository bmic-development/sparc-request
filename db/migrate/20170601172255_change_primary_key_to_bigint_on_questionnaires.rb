class ChangePrimaryKeyToBigintOnQuestionnaires < ActiveRecord::Migration[5.0]
  def change
    remove_reference :submissions, :questionnaire, index: true, foreign_key: true
    remove_reference :items, :questionnaire, index: true, foreign_key: true
    change_column :questionnaires, :id, :bigint
    add_reference :submissions, :questionnaire, type: :bigint, index: true, foreign_key: true
    add_reference :items, :questionnaire, type: :bigint, index: true, foreign_key: true
  end
end
