task multiple_ssrs: :environment do
  orgs = [64, 131]
  CSV.open("tmp/multiple_ssrs.csv", "w") do |csv|
    csv << ['Protocol ID', 'Protocol Short Title', 'ServiceRequest ID', 'SSR Orgs']
    orgs.map do |org_id|
      ServiceRequest.
        joins(:sub_service_requests).
        where(sub_service_requests: { organization_id: org_id }).
        where.not(sub_service_requests: { status: ['complete', 'first_draft'] }).
        group_by(&:protocol_id).map do |protocol_id, srs|
          next if srs.count == 1 && srs.first.sub_service_requests.where(organization_id: org_id).where.not(sub_service_requests: { status: ['complete', 'first_draft'] }).count == 1 || protocol_id.nil?
          srs
        end
    end.flatten.compact.uniq.group_by(&:protocol_id).map do |protocol_id, srs|
      next unless protocol_id
      short_title = Protocol.find(protocol_id).short_title rescue "?"
      srs.each do |sr|
        csv << [sr.protocol_id, short_title, sr.id, sr.sub_service_requests.where(organization_id: orgs).where.not(sub_service_requests: { status: ['complete', 'first_draft'] }).pluck(:organization_id)]
      end
    end
  end
end
