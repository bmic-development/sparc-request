class ChangePrimaryKeyToBigIntOnHumanSubjectsInfo < ActiveRecord::Migration[5.0]
  def change
    change_column :human_subjects_info, :id, :bigint
  end
end
