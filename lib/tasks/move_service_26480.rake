task :move_service_26480 => :environment do
  ### Move service "Order/SmartSets" (service.id = 26480) 
  ### to a new organization "Prospective Reimbursement Analysis (PRA)" (organizations.id = 248)
  service_to_be_moved = Service.find(26480)
  service_to_be_moved.update_attribute(:organization_id, 248)

  ### After moving the service, please also move or separate out the existing 
  ### line_items to a new sub-service-request for the new parent organization (248) accordingly.
  LineItem.where(service_id: 26480).each do |li|
    old_ssr = li.sub_service_request
    new_ssr = li.service_request.sub_service_requests.create(organization_id: 248)
    li.service_request.ensure_ssr_ids
    li.update_attribute(:sub_service_request_id, new_ssr.id)
    if old_ssr.line_items.empty?
      old_ssr.destroy
    end
  end
end