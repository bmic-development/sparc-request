class ChangePrimaryKeyToBigintOnProtocolsStudyPhases < ActiveRecord::Migration[5.0]
  def change
    change_column :protocols_study_phases, :protocol_id, :bigint
    change_column :protocols_study_phases, :study_phase_id, :bigint
  end
end
