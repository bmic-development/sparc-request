class ChangePrimaryKeyToBigIntOnDelayedJobs < ActiveRecord::Migration[5.0]
  def change
    change_column :delayed_jobs, :id, :bigint
  end
end
