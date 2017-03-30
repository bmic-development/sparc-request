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
  
   describe 'PUT #create_line_items' do

    context 'SUCCESS' do

      before(:each) do
        log_in_dashboard_identity(obj: build_stubbed(:identity))
        @service_request = create(:service_request_without_validations, arms: [], protocol: create(:protocol_without_validations))
        @sub_service_request = findable_stub(SubServiceRequest) do 
          build_stubbed(:sub_service_request, service_request: @service_request)
        end
        @existing_line_items = create_list(:line_item_without_validations, 3)
        @service = create(:service_without_validations, line_items: @existing_line_items)
        xhr :put, :create_line_items, 
            service_request_id: @service_request.id,
            sub_service_request_id: @sub_service_request.id,
            add_service_id: @service.id
      end

      it 'assigns the correct service request' do
        expect(assigns(:service_request)).to eq(@service_request)
      end

      it 'assigns the correct ssr' do
        expect(assigns(:sub_service_request)).to eq(@sub_service_request)
      end

      it 'assigns the correct service' do
        expect(assigns(:service)).to eq(@service)
      end
      it 'creates a default arm when the service request does not have one' do
        expect(assigns(:service_request).arms.length).to eq(1)
      end

      it 'calls the correct service request method' do
        expect(assigns(:service_request)).to respond_to(:create_line_items_for_service)
      end

      it 'calls the correct ssr method' do
        expect(assigns(:sub_service_request)).to respond_to(:update_cwf_data_for_new_line_item)
      end

      it 'creates a line item with the correct service' do
        expect(assigns(:new_line_items).first.service_id).to eq(@service.id)
      end

      it 'creates a line item with the correct service request' do
        expect(assigns(:new_line_items).first.service_request_id).to eq(@service_request.id)
      end

      it 'creates a line item with the correct ssr' do
        expect(assigns(:new_line_items).first.sub_service_request_id).to eq(@sub_service_request.id)
      end

      it 'creates a line item with the correct optional attribute' do
        expect(assigns(:new_line_items).first.optional).to eq(true)
      end
    end

    context 'FAILURE' do
      before(:each) do
        log_in_dashboard_identity(obj: build_stubbed(:identity))
        @service_request = findable_stub(ServiceRequest) do
          build_stubbed(:service_request_without_validations, arms: [], protocol: create(:protocol_without_validations))
        end
        @sub_service_request = findable_stub(SubServiceRequest) do 
          build_stubbed(:sub_service_request, service_request: @service_request)
        end
        @existing_line_items = create_list(:line_item_without_validations, 3)
        @service = create(:service_without_validations, line_items: @existing_line_items)
        allow(@service_request).to receive(:create_line_items_for_service){ nil }
        allow(@service_request).to receive(:errors){ 'Test error' }
        xhr :put, :create_line_items, 
            service_request_id: @service_request.id,
            sub_service_request_id: @sub_service_request.id,
            add_service_id: @service.id
      end

      it 'produces the correct error' do
        expect(assigns(:errors)).to eq('Test error')
      end

      it 'does not assign new_line_items' do
        expect(assigns(:new_line_items)).to eq(nil)
      end
    end
  end
end