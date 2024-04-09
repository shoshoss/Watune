require 'rails_helper'

RSpec.describe "Renders", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/render/index"
      expect(response).to have_http_status(:success)
    end
  end

end
