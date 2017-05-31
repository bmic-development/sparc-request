class ChangePrimaryKeyToBigIntOnAssociatedSurveys < ActiveRecord::Migration[5.0]
  def change
    change_column :associated_surveys, :id, :bigint
  end
end
