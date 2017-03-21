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
  
   describe 'GET #new_line_items' do

    before(:all) do
      log_in_dashboard_identity(obj: build_stubbed(:identity))
      @service_request = create(:service_request_without_validations)
      @sub_service_request = findable_stub(SubServiceRequest) do 
        build_stubbed(:sub_service_request, service_request: @service_request)
      end
      @services = create_list(:service, 3)
      allow(@sub_service_request).to receive(:candidate_services){@services}
      @protocol = create(:protocol_without_validations)
      @page_hash = "test page hash"
      @schedule_tab = "test schedule tab"
      xhr :get, :new_line_items, 
          service_request_id: @service_request.id,
          sub_service_request_id: @sub_service_request.id,
          protocol_id: @protocol.id,
          page_hash: @page_hash,
          schedule_tab: @schedule_tab
    end

    it 'responds with 200' do
      expect(response.status).to eq(200)
    end

    it 'assigns service request' do
      expect(assigns(:service_request)).to eq(@service_request)
    end

    it 'assigns sub service request' do
      expect(assigns(:sub_service_request)).to eq(@sub_service_request)
    end

    it 'assigns protocol' do
      expect(assigns(:protocol)).to eq(@protocol)
    end

    it 'assigns services' do
      expect(assigns(:services)).to eq(@services)
    end

    it 'assigns page hash' do
      expect(assigns(:page_hash)).to eq(@page_hash)
    end

    it 'assigns schedule tab' do
      expect(assigns(:study_tab)).to eq(@study_tab)
    end
  end
end