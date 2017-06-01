class ChangePrimaryKeyToBigintOnQuickQuestions < ActiveRecord::Migration[5.0]
  def change
    change_column :quick_questions, :id, :bigint
  end
end
