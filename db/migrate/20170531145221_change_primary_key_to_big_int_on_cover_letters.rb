class ChangePrimaryKeyToBigIntOnCoverLetters < ActiveRecord::Migration[5.0]
  def change
    change_column :cover_letters, :id, :bigint
  end
end
