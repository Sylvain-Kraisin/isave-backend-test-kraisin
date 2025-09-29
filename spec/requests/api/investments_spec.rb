require "rails_helper"

RSpec.describe "Investments API (deposit/withdraw)", type: :request do
  let!(:customer) { Customer.create!(first_name: "Jane", last_name: "Doe") }
  let!(:portfolio) { customer.portfolios.create!(name: "CTO - Actions", kind: "CTO", total_amount: 1000) }
  let!(:instrument) { Instrument.create!(isin: "FR0000000001", kind: "stock", name: "ETF", price: 100, sri: 5) }
  let!(:investment) { portfolio.investments.create!(instrument: instrument, amount: 500, weight: 0.5) }

  describe "POST /api/v1/customers/:customer_id/portfolios/:portfolio_id/investments/:id/deposit" do
    it "adds to the investment and portfolio totals" do
      post "/api/v1/customers/#{customer.id}/portfolios/#{portfolio.id}/investments/#{instrument.id}/deposit", params: { amount: 100 }
      expect(response).to have_http_status(:no_content)
      expect(investment.reload.amount).to eq(600)
      expect(portfolio.reload.total_amount).to eq(1100)
    end

    it "rejects negative or zero amounts (400)" do
      post "/api/v1/customers/#{customer.id}/portfolios/#{portfolio.id}/investments/#{instrument.id}/deposit", params: { amount: 0 }
      expect(response).to have_http_status(:bad_request)
    end
  end

  describe "POST /api/v1/customers/:customer_id/portfolios/:portfolio_id/investments/:id/withdraw" do
    it "subtracts from the investment and portfolio totals" do
      post "/api/v1/customers/#{customer.id}/portfolios/#{portfolio.id}/investments/#{instrument.id}/withdraw", params: { amount: 200 }
      expect(response).to have_http_status(:no_content)
      expect(investment.reload.amount).to eq(300)
      expect(portfolio.reload.total_amount).to eq(800)
    end

    it "fails with 422 on insufficient funds" do
      post "/api/v1/customers/#{customer.id}/portfolios/#{portfolio.id}/investments/#{instrument.id}/withdraw", params: { amount: 10000 }
      expect(response).to have_http_status(:unprocessable_entity)
      body = JSON.parse(response.body) rescue {}
      expect(body.dig("error", "code")).to eq("validation_error").or eq("not_eligible")
    end
  end

  context "when portfolio not eligible (Assurance Vie)" do
    let!(:non_eligible) { customer.portfolios.create!(name: "Assurance Vie - épargne", kind: "Assurance Vie", total_amount: 1000) }
    let!(:inv2) { non_eligible.investments.create!(instrument: instrument, amount: 100, weight: 0.1) }

    it "returns 422 not_eligible on deposit" do
      post "/api/v1/customers/#{customer.id}/portfolios/#{non_eligible.id}/investments/#{instrument.id}/deposit", params: { amount: 50 }
      expect(response).to have_http_status(:unprocessable_entity)
      body = JSON.parse(response.body) rescue {}
      expect(body.dig("error", "code")).to eq("not_eligible")
    end
  end
end


