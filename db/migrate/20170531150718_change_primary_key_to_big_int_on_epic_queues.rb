class ChangePrimaryKeyToBigIntOnEpicQueues < ActiveRecord::Migration[5.0]
  def change
    change_column :epic_queues, :id, :bigint
  end
end
