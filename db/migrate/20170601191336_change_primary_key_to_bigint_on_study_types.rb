class ChangePrimaryKeyToBigintOnStudyTypes < ActiveRecord::Migration[5.0]
  def change
    change_column :study_types, :id, :bigint
  end
end
