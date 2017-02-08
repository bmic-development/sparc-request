require 'rails_helper'

RSpec.describe ViewDetailsController, type: :controller do

  describe "GET #view_details" do
    it "returns http success" do
      protocol = create(:protocol_without_validations)
      get :show, protocol_id: protocol, format: :js
      expect(response).to have_http_status(:success)
    end
  end
end
