class ChangePrimaryKeyToBigintOnReports < ActiveRecord::Migration[5.0]
  def change
    change_column :reports, :id, :bigint
  end
end
