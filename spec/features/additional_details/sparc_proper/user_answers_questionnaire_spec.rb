require 'rails_helper'

RSpec.describe 'User answers an additional details questionnaire', js: true do
  let_there_be_lane
  fake_login_for_each_test

  before :each do
    institution   = create(:institution, name: "Institution")
    provider      = create(:provider, name: "Provider", parent: institution)
    program       = create(:program, name: "Program", parent: provider, process_ssrs: true)
    service       = create(:service_with_pricing_map, name: 'Brain Removal')
    @protocol     = create(:protocol_federally_funded, type: 'Study', primary_pi: jug2)
    @sr           = create(:service_request_without_validations, status: 'first_draft', protocol: @protocol)
    ssr           = create(:sub_service_request_without_validations, service_request: @sr, organization: program, status: 'first_draft')
                    create(:line_item, service_request: @sr, sub_service_request: ssr, service: service)
                    create(:arm, protocol: @protocol, visit_count: 1)
    questionnaire = create(:questionnaire, service: service, name: 'Does your brain hurt?')
    item          = create(:item, questionnaire: questionnaire, content: 'How is your brain? Does it hurt and need to be removed?',
                           item_type: 'yes_no')
    visit document_management_service_request_path(@sr)
    wait_for_javascript_to_finish
  end

  describe 'user visits the documents page' do

    it 'and should see the questionnaire' do
      within '.document-management-submissions' do
        expect(page).to have_content('Brain Removal')
      end
    end   
  end
end