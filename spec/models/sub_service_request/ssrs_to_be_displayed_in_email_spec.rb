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

RSpec.describe SubServiceRequest, type: :model do
  let_there_be_lane
  let_there_be_j
  build_service_request_with_study

  describe "#ssrs_to_be_displayed_in_email" do
      
    context "ssr_deleted == true" do
      before :each do
        @identity = Identity.find(jug2.id)
        service_request.update_attribute(:submitted_at, Time.now.yesterday)
        service_request.sub_service_requests.each do |ssr|
          ssr.update_attribute(:submitted_at, Time.now.yesterday)
          ssr.update_attribute(:status, 'submitted')
          li_id = ssr.line_items.first.id
          ssr.line_items.first.destroy!
          ssr.save!
          service_request.reload
          @audit = AuditRecovery.where("auditable_id = '#{li_id}' AND auditable_type = 'LineItem' AND action = 'destroy'")
        end
        
        @audit.first.update_attribute(:created_at, Time.now - 5.hours)
        @audit.first.update_attribute(:user_id, @identity.id)
        @report = service_request.sub_service_requests.first.audit_report(@identity, Time.now.yesterday - 4.hours, Time.now.tomorrow)
      end
      it "should return the ssr with deleted line_item" do
        expect(service_request.sub_service_requests.first.ssrs_to_be_displayed_in_email(service_provider, service_request, @report, true)).to eq([service_request.sub_service_requests.first])
      end
    end

    context "ssr_deleted == false" do
      it "should return all ssrs belonging to service_provider" do
        expect(service_request.sub_service_requests.first.ssrs_to_be_displayed_in_email(service_provider, service_request, @report, false)).to eq(service_request.sub_service_requests)
      end
    end
  end
end