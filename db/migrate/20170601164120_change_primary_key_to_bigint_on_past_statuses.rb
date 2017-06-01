class ChangePrimaryKeyToBigintOnPastStatuses < ActiveRecord::Migration[5.0]
  def change
    change_column :past_statuses, :id, :bigint
  end
end
