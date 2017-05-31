class ChangePrimaryKeyToBigIntOnFeedbacks < ActiveRecord::Migration[5.0]
  def change
    change_column :feedbacks, :id, :bigint
  end
end
