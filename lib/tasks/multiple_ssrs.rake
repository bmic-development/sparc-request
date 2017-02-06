task multiple_ssrs: :environment do
  orgs = [64, 131]
  CSV.open("tmp/multiple_ssrs.csv", "w") do |csv|
    csv << ['Protocol ID', 'Protocol Short Title', 'ServiceRequest ID', 'SSR_ID', 'Organization']
    results = orgs.map do |org_id|
      Protocol.joins(:sub_service_requests).
        where(sub_service_requests: { organization_id: org_id }).
        where.not(sub_service_requests: { status: ['complete', 'first_draft'] }).
        distinct.
        map do |protocol|
          ssrs = protocol.sub_service_requests.where(sub_service_requests: { organization_id: org_id }).
                          where.not(sub_service_requests: { status: ['complete', 'first_draft'] })
          next if ssrs.count < 2
          [protocol.id, ssrs]
        end.compact
    end.flatten(1).map do |protocol_id, ssrs|
      # Skip protocol_id == nil.
      next unless protocol_id
      short_title = Protocol.find(protocol_id).short_title rescue "?"
      ssrs.group_by(&:service_request_id).each do |service_request_id, some_ssrs|
        some_ssrs.each do |ssr|
          csv << [protocol_id, short_title, service_request_id, ssr.ssr_id, ssr.organization_id]
        end
      end
    end
  end
end
