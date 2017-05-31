class ChangePrimaryKeyToBigIntOnDocuments < ActiveRecord::Migration[5.0]
  def change
    change_column :documents, :id, :bigint
  end
end
