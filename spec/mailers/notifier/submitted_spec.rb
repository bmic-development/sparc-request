require 'rails_helper'

RSpec.describe Notifier do

  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_project

  let(:service3)           { create(:service,
                                    organization_id: program.id,
                                    name: 'ABCD',
                                    one_time_fee: true) }
  let(:pricing_setup)     { create(:pricing_setup,
                                    organization_id: program.id,
                                    display_date: Time.now - 1.day,
                                    federal: 50,
                                    corporate: 50,
                                    other: 50,
                                    member: 50,
                                    college_rate_type: 'federal',
                                    federal_rate_type: 'federal',
                                    industry_rate_type: 'federal',
                                    investigator_rate_type: 'federal',
                                    internal_rate_type: 'federal',
                                    foundation_rate_type: 'federal') }
  let(:pricing_map)       { create(:pricing_map,
                                    unit_minimum: 1,
                                    unit_factor: 1,
                                    service: service3,
                                    quantity_type: 'Each',
                                    quantity_minimum: 5,
                                    otf_unit_type: 'Week',
                                    display_date: Time.now - 1.day,
                                    full_rate: 2000,
                                    units_per_qty_max: 20) }
  let(:identity)          { Identity.first }
  let(:organization)      { Organization.first }
  let(:non_service_provider_org)  { create(:organization, name: 'BLAH', process_ssrs: 0, is_available: 1) }
  let(:service_provider)  { create(:service_provider,
                                    identity: identity,
                                    organization: organization,
                                    service: service3) }
  let!(:non_service_provider_ssr) { create(:sub_service_request, ssr_id: "0004", status: "submitted", service_request_id: service_request.id, organization_id: non_service_provider_org.id, org_tree_display: "SCTR1/BLAH")}

  let(:previously_submitted_at) { service_request.submitted_at.nil? ? Time.now.utc : service_request.submitted_at.utc }
  let(:audit)                   { sub_service_request.audit_report(identity,
                                                                      previously_submitted_at,
                                                                      Time.now.utc) }

  before { add_visits }

  # SUBMITTED
  before do
    service_request.update_attribute(:status, "submitted")
  end

  ############# WITHOUT NOTES #########################
  context 'without notes' do

    context 'service_provider' do
      let(:xls)                     { Array.new }
      let(:mail)                    { Notifier.notify_service_provider(service_provider,
                                                                          service_request,
                                                                          xls,
                                                                          identity,
                                                                          audit) }
      # Expected service provider message is defined under submitted_service_provider_and_admin_message
      it 'should display service provider intro message, conclusion, link, and should not display acknowledgments' do
        submitted_intro_for_service_providers_and_admin(mail)
      end

      it 'should render default tables' do
        assert_notification_email_tables_for_service_provider
      end

      it 'should have a notes reminder message but not a submission reminder' do
        does_not_have_a_reminder_note(mail)
        does_not_have_a_submission_reminder(mail)
      end

      it 'should not have audited information table' do
        expect(mail).not_to have_xpath("//th[text()='Service']/following-sibling::th[text()='Action']")
      end
    end

    context 'users' do
      let(:xls)                     { ' ' }
      let(:project_role)            { service_request.protocol.project_roles.select{ |role| role.project_rights != 'none' && !role.identity.email.blank? }.first }
      let(:approval)                { service_request.approvals.create }
      let(:mail)                    { Notifier.notify_user(project_role,
                                                              service_request,
                                                              xls,
                                                              approval,
                                                              identity
                                                              ) }
      # Expected user message is defined under submitted_general_users_message
      it 'should have user intro message, conclusion, and acknowledgments' do
        submitted_intro_for_general_users
      end

      it 'should render default tables' do
        assert_notification_email_tables_for_user
      end

      it 'should have a notes reminder message but not a submission reminder' do
        does_not_have_a_reminder_note(mail.body.parts.first.body)
        does_have_a_submission_reminder(mail.body.parts.first.body)
      end
    end

    context 'admin' do

      let(:xls)                       { ' ' }
      let(:submission_email_address)  { 'success@musc.edu' }
      let(:mail)                      { Notifier.notify_admin(service_request,
                                                                submission_email_address,
                                                                xls,
                                                                identity) }

      # Expected admin message is defined under submitted_service_provider_and_admin_message
      it 'should display admin intro message, conclusion, link, and should not display acknowledgments' do
        submitted_intro_for_service_providers_and_admin(mail.body.parts.first.body)
      end

      it 'should render default tables' do
        assert_notification_email_tables_for_admin
      end

      it 'should have a notes reminder message but not a submission reminder' do
        does_not_have_a_reminder_note(mail.body.parts.first.body)
        does_not_have_a_submission_reminder(mail.body.parts.first.body)
      end
    end
  end

  ############# WITH NOTES #########################
  context 'with notes' do

    before do
      create(:note_without_validations,
            identity_id:  identity.id, 
            notable_id: service_request.id)
    end

    context 'service_provider' do
      let(:xls)                     { Array.new }
      let(:mail)                    { Notifier.notify_service_provider(service_provider,
                                                                          service_request,
                                                                          xls,
                                                                          identity,
                                                                          audit) }
      # Expected service provider message is defined under submitted_service_provider_and_admin_message
      it 'should display admin intro message, conclusion, link, and should not display acknowledgments' do
        submitted_intro_for_service_providers_and_admin(mail)
      end

      it 'should render default tables' do
        assert_notification_email_tables_for_service_provider
      end

      it 'should have a notes reminder message but not a submission reminder' do
        does_have_a_reminder_note(mail)
        does_not_have_a_submission_reminder(mail)
      end

      it 'should not have audited information table' do
        expect(mail).not_to have_xpath("//th[text()='Service']/following-sibling::th[text()='Action']")
      end
    end

    context 'users' do
      let(:xls)                     { ' ' }
      let(:project_role)            { service_request.protocol.project_roles.select{ |role| role.project_rights != 'none' && !role.identity.email.blank? }.first }
      let(:approval)                { service_request.approvals.create }
      let(:mail)                    { Notifier.notify_user(project_role,
                                                              service_request,
                                                              xls,
                                                              approval,
                                                              identity
                                                              ) }
      # Expected user message is defined under submitted_general_users_message
      it 'should have user intro message, conclusion, and acknowledgments' do
        submitted_intro_for_general_users
      end

      it 'should render default tables' do
        assert_notification_email_tables_for_user
      end

      it 'should NOT have a notes reminder message but have a submission reminder' do
        does_not_have_a_reminder_note(mail.body.parts.first.body)
        does_have_a_submission_reminder(mail.body.parts.first.body)
      end
    end

    context 'admin' do
      let(:xls)                       { ' ' }
      let(:submission_email_address)  { 'success@musc.edu' }
      let(:mail)                      { Notifier.notify_admin(service_request,
                                                                submission_email_address,
                                                                xls,
                                                                identity) }
      # Expected service provider message is defined under submitted_service_provider_and_admin_message
      it 'should display admin intro message, conclusion, link, and should not display acknowledgments' do
        submitted_intro_for_service_providers_and_admin(mail.body.parts.first.body)
      end

      it 'should render default tables' do
        assert_notification_email_tables_for_admin
      end

      it 'should have a notes reminder message but not a submission reminder' do
        does_have_a_reminder_note(mail)
        does_not_have_a_submission_reminder(mail)
      end
    end
  end
end