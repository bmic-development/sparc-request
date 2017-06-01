class ChangePrimaryKeyToBigintOnSubServiceRequests < ActiveRecord::Migration[5.0]
  def change
    remove_reference :responses, :sub_service_request, index: true, foreign_key: true
    change_column :sub_service_requests, :id, :bigint
    add_reference :responses, :sub_service_request, type: :bigint, index: true, foreign_key: true
  end
end
