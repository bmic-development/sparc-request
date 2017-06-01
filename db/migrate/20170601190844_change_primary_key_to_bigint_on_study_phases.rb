class ChangePrimaryKeyToBigintOnStudyPhases < ActiveRecord::Migration[5.0]
  def change
    change_column :study_phases, :id, :bigint
  end
end
