class ChangePrimaryKeyToBigintOnServiceRequests < ActiveRecord::Migration[5.0]
  def change
    change_column :service_requests, :id, :bigint
  end
end
