class ChangePrimaryKeyToBigintOnSurveys < ActiveRecord::Migration[5.0]
  def change
    remove_reference :sections, :survey, index: true, foreign_key: true
    remove_reference :responses, :survey, index: true, foreign_key: true
    change_column :surveys, :id, :bigint
    add_reference :sections, :survey, type: :bigint, index: true, foreign_key: true
    add_reference :responses, :survey, type: :bigint, index: true, foreign_key: true
  end
end
