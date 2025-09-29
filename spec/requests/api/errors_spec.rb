require "rails_helper"

RSpec.describe "API error handling", type: :request do
  describe "GET /api/v1/customers/:customer_id/portfolios when customer does not exist" do
    it "returns JSON 404 with error payload" do
      get "/api/v1/customers/999999/portfolios"
      expect(response).to have_http_status(:not_found)
      body = JSON.parse(response.body) rescue {}
      expect(body).to be_a(Hash)
      expect(body.dig("error", "code")).to eq("not_found")
    end
  end

  describe "GET unknown API route" do
    it "returns JSON 404 with error payload" do
      get "/api/v1/this/route/does/not/exist"
      expect(response).to have_http_status(:not_found)
      body = JSON.parse(response.body) rescue {}
      expect(body.dig("error", "code")).to eq("not_found")
      expect(body.dig("error", "message")).to be_present
    end
  end
end


