class ChangePrimaryKeyToBigintOnSubmissionEmails < ActiveRecord::Migration[5.0]
  def change
    change_column :submission_emails, :id, :bigint
  end
end
