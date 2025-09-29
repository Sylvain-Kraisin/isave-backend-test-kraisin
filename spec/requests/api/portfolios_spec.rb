require "rails_helper"

RSpec.describe "Portfolios API", type: :request do
  describe "GET /api/v1/customers/:customer_id/portfolios" do
    context "when customer exists" do
      it "returns portfolios in the expected JSON shape with contracts and lines" do
        customer = Customer.create!(first_name: "Test", last_name: "User")

        portfolio = customer.portfolios.create!(name: "PEA - Portefeuille Équilibré", kind: "PEA", total_amount: 30000)
        instrument = Instrument.create!(isin: "FR0012345678", kind: "stock", name: "iShares Core MSCI World ETF", price: 50, sri: 6)
        portfolio.investments.create!(instrument: instrument, amount: 20000, weight: 0.34)

        get "/api/v1/customers/#{customer.id}/portfolios"
        expect(response).to have_http_status(:ok), "expected 200 OK, got #{response.status} with body: #{response.body}"

        json = JSON.parse(response.body)
        expect(json).to include("contracts")
        expect(json["contracts"]).to be_an(Array)

        first = json["contracts"].first
        expect(first).to include(
          "label" => "PEA - Portefeuille Équilibré",
          "type" => "PEA",
          "amount" => 30000.0
        )
        expect(first["lines"]).to be_an(Array)
        line = first["lines"].first
        expect(line).to include(
          "type" => "stock",
          "isin" => "FR0012345678",
          "label" => "iShares Core MSCI World ETF",
          "price" => 50.0,
          "share" => 0.34,
          "amount" => 20000.0,
          "srri" => 6
        )
      end

      it "returns only portfolios belonging to the given customer" do
        c1 = Customer.create!(first_name: "C1", last_name: "User")
        c2 = Customer.create!(first_name: "C2", last_name: "User")

        c1.portfolios.create!(name: "P1", kind: "CTO", total_amount: 100)
        c1.portfolios.create!(name: "P2", kind: "PEA", total_amount: 200)
        c2.portfolios.create!(name: "P3", kind: "Livret A", total_amount: 300)

        get "/api/v1/customers/#{c1.id}/portfolios"
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        labels = body.fetch("contracts").map { |h| h["label"] }
        expect(labels).to match_array(["P1", "P2"]) 
      end
    end

    context "when customer does not exist" do
      it "returns JSON 404 error payload" do
        get "/api/v1/customers/999999/portfolios"
        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body) rescue {}
        expect(json.dig("error", "code")).to eq("not_found")
      end
    end
  end
end


