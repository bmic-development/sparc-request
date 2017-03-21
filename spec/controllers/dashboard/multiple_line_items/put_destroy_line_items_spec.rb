# Copyright © 2011-2016 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

require 'rails_helper'

RSpec.describe Dashboard::MultipleLineItemsController do
  
   describe 'PUT #destroy_line_items' do

    before(:each) do
      log_in_dashboard_identity(obj: build_stubbed(:identity))
      @service_request = create(:service_request_without_validations)
      @service = create(:service)
      organization    = create(:organization, process_ssrs: true)
      protocol        = create(:protocol_without_validations)
      @sub_service_request = create(:sub_service_request_without_validations,
                              organization: organization,
                              service_request: @service_request,
                              status: 'draft',
                              protocol: protocol)

      @line_items = create_list(:per_patient_per_visit_line_item, 3,
                                 service: @service, 
                                 quantity: 1, 
                                 service_request: @service_request, 
                                 sub_service_request: @sub_service_request)

      allow(@sub_service_request).to receive(:candidate_services){ @services }
    end

    it 'deletes the line items from the sub service request' do
      expect{ xhr :put, :destroy_line_items, 
                        service_request_id: @service_request.id,
                        sub_service_request_id: @sub_service_request.id,
                        remove_service_id: @service.id
                        }.to change{ @sub_service_request.line_items.count }.from(3).to(0)
    end

    it 'shows the correct flash message' do
      xhr :put, :destroy_line_items, 
                service_request_id: @service_request.id,
                sub_service_request_id: @sub_service_request.id,
                remove_service_id: @service.id

      expect(flash.now[:alert]).to eq("Services Removed!")
    end
  end
end