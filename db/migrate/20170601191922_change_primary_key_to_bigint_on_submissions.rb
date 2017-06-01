class ChangePrimaryKeyToBigintOnSubmissions < ActiveRecord::Migration[5.0]
  def change
    remove_reference :questionnaire_responses, :submission, index: true, foreign_key: true
    change_column :submissions, :id, :bigint
    add_reference :questionnaire_responses, :submission, type: :bigint, index: true, foreign_key: true
  end
end
