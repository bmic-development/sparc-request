require 'progress_bar'

AUDIT_COMMENT = "success_merge"

task :success_merge => :environment do
  merge_srs_under_orgs([2, 11, 20, 36, 63, 180])
end

# Destroy SSRs under protocol under a status in statuses param.
def clean_ssrs(protocol, statuses)
  protocol.sub_service_requests.where(status: statuses).each(&:destroy)
end

def merge_srs_under_orgs(org_ids)
  ServiceRequest.skip_callback(:save, :after, :set_original_submitted_date)
  multiple_ssrs_fp = CSV.open("tmp/multiple_ssrs.csv", "w")
  deleted_ssrs_fp = CSV.open("tmp/deleted_ssrs.csv", "w")

  multiple_ssrs_fp << ['Protocol ID', 'short title', 'ssr_id', 'Organization ID', 'Organization Name', 'SSR status', 'SSR pushed to Fulfillment?', 'SR ID', 'SR Submission date']
  deleted_ssrs_fp << ['Protocol ID', 'short title', 'ssr_id', 'Organization ID', 'Organization Name', 'SSR status', 'SSR pushed to Fulfillment?', 'SR ID', 'SR Submission date']

  # For each Protocol that has a Nexus SSR
  protocols = Protocol.joins(:sub_service_requests).where(sub_service_requests: { organization_id: org_ids }).distinct
  bar1 = ProgressBar.new(protocols.count)
  protocols.each do |protocol|
    clean_ssrs(protocol, ['draft', 'first_draft'])

    # Reload Nexus SSR's
    nexus_ssrs = protocol.sub_service_requests.where(organization_id: org_ids)

    # If we still have multiple Nexus SSR's
    if nexus_ssrs.count > 1
      # Log them and any other SSR's with multiplicity
      protocol.sub_service_requests.group_by(&:organization_id).each do |organization_id, ssrs|
        next unless ssrs.count > 1
        ssrs.each do |ssr|
          multiple_ssrs_fp << [protocol.id, protocol.short_title, ssr.ssr_id,
            ssr.organization_id, ssr.organization.name, ssr.status,
            ssr.in_work_fulfillment?, ssr.service_request_id,
            ssr.service_request.submitted_at]
        end
      end
    end

    bar1.increment!
  end

  multiple_ssrs_fp.close
  deleted_ssrs_fp.close

  cant_delete_fp = CSV.open("tmp/multiple_ssrs_cant_delete.csv", "w")
  cant_delete_fp << ['Service Request ID']

  # For each Protocol that has a Nexus SSR
  protocols = Protocol.joins(:sub_service_requests).where(sub_service_requests: { organization_id: org_ids }).distinct
  bar2 = ProgressBar.new(protocols.count)
  protocols.each do |protocol|
    # Grab all Nexus SSR's
    nexus_ssrs = protocol.sub_service_requests.where(organization_id: org_ids)

    # If there are multiple Nexus SSR's
    if nexus_ssrs.count > 1
      # Then something is wrong
      raise "Protocol #{protocol.id} has multiple SSR's under Organization 14"
    end

    delete_empty_srs(protocol)

    # Merge remaining service requests into service request with most recently
    # updated status
    recent_service_request = protocol.service_requests.preload(:audits).distinct.map do |sr|
      last_status_change = sr.audits.reverse.find { |a| a.audited_changes["status"] }
      if last_status_change
        [sr, last_status_change.created_at]
      end
    end.compact.sort do |l, r|
      l[1] <=> r[1]
    end

    recent_service_request = if recent_service_request.empty?
      # If audit trail runs out, use most recently updated ServiceRequest
      protocol.service_requests.order(:updated_at).last
    else
      recent_service_request.last[0]
    end

    # And the latest submitted_at date
    latest_submitted_at = protocol.service_requests.
      order(:submitted_at).
      where.not(submitted_at: nil).
      pluck(:submitted_at).
      last

    if latest_submitted_at
      recent_service_request.assign_attributes({ submitted_at: latest_submitted_at, audit_comment: AUDIT_COMMENT }, without_protection: true)
      recent_service_request.save(validate: false)
    end

    # Keep the earliest original_submitted_date among service requests
    earliest_original_submitted_date = protocol.service_requests.
      order(:original_submitted_date).
      where.not(original_submitted_date: nil).
      pluck(:original_submitted_date).
      first

    if earliest_original_submitted_date
      recent_service_request.assign_attributes({ original_submitted_date: earliest_original_submitted_date, audit_comment: AUDIT_COMMENT }, without_protection: true)
      recent_service_request.save(validate: false)
    end

    # Move all SSR's, LineItems and ServiceRequest Notes under this recent_service_request
    protocol.sub_service_requests.where.not(service_request_id: recent_service_request.id).each do |ssr|
      ssr.assign_attributes({ service_request_id: recent_service_request.id, audit_comment: AUDIT_COMMENT }, without_protection: true)
      ssr.save
    end
    line_items = LineItem.joins(:service_request).where(service_requests: { protocol_id: protocol.id }).where.not(service_request_id: recent_service_request.id)
    line_items.each do |li|
      li.assign_attributes({ service_request_id: recent_service_request.id, audit_comment: AUDIT_COMMENT }, without_protection: true)
      li.save(validate: false)
    end

    protocol.service_requests.where.not(id: recent_service_request.id).each do |sr|
      sr.notes.each do |note|
        note.assign_attributes({ notable_id: recent_service_request.id, audit_comment: AUDIT_COMMENT }, without_protection: true)
        note.save(validate: false)
      end
    end

    delete_empty_srs(protocol)

    bar2.increment!
  end

  cant_delete_fp.close
end

def delete_empty_srs(protocol)
  protocol.service_requests.includes(:sub_service_requests).where(sub_service_requests: { id: nil }).each do |sr|
    begin
      sr.destroy
      sr.audits.last.update(comment: AUDIT_COMMENT)
    rescue
      # Probably a funky Note body...
      sr.notes.each do |note|
        note.assign_attributes({ notable_id: nil, audit_comment: AUDIT_COMMENT }, without_protection: true)
        note.save(validate: false)
      end
      sr.reload.destroy
      sr.audits.last.update(comment: AUDIT_COMMENT)
    end
  end
end
