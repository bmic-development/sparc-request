class ChangePrimaryKeyToBigIntOnEpicQueueRecords < ActiveRecord::Migration[5.0]
  def change
    change_column :epic_queue_records, :id, :bigint
  end
end
