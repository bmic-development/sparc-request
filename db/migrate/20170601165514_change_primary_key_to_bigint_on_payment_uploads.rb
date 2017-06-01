class ChangePrimaryKeyToBigintOnPaymentUploads < ActiveRecord::Migration[5.0]
  def change
    change_column :payment_uploads, :id, :bigint
  end
end
