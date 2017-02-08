require 'rails_helper'

RSpec.describe 'User should be able to view the protocol details', js: true do
  let!(:user) do
    create(:identity,
           last_name: "Doe",
           first_name: "John",
           ldap_uid: "johnd",
           email: "johnd@musc.edu",
           password: "p4ssword",
           password_confirmation: "p4ssword",
           approved: true)
  end

  fake_login_for_each_test("johnd")

  scenario 'from summary in dashboard' do
    protocol = create(
      :unarchived_study_without_validations,
      primary_pi: user
    )

    visit dashboard_protocol_path(protocol)
    find('.view-protocol-details-button').click

    expect(page).to have_content "#{protocol.short_title}"
  end

  scenario 'from Step 1 in proper' do
    institution = create(:institution, name: "Institution")
    provider    = create(:provider, name: "Provider", parent: institution)
    program     = create(
      :program, name: "Program", parent: provider, process_ssrs: true
    )
    service     = create(
      :service, name: "Service", abbreviation: "Service", organization: program
    )
    protocol = create(
      :unarchived_study_without_validations,
      primary_pi: user,
      research_master_id: 1
    )
    sr = create(
      :service_request_without_validations,
      status: 'first_draft',
      protocol: protocol
    )
    ssr = create(
      :sub_service_request_without_validations,
      service_request: @sr, organization: program, status: 'first_draft'
    )
    create(
      :line_item,
      service_request: sr, sub_service_request: ssr, service: service
    )
    create(:arm, protocol: protocol, visit_count: 1)
    create(
      :subsidy_map, organization: program, max_dollar_cap: 100, max_percentage: 100
    )

    visit protocol_service_request_path(sr)

    find('.view-protocol-details-button').click
    
    expect(page).to have_content "#{protocol.short_title}"
  end
end