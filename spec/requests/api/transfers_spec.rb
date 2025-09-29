require "rails_helper"

RSpec.describe "Transfers API", type: :request do
  let!(:customer) { Customer.create!(first_name: "John", last_name: "Doe") }
  let!(:portfolio) { customer.portfolios.create!(name: "PEA - EQ", kind: "PEA", total_amount: 1000) }
  let!(:i1) { Instrument.create!(isin: "FR0000000002", kind: "stock", name: "ETF 1", price: 100, sri: 5) }
  let!(:i2) { Instrument.create!(isin: "FR0000000003", kind: "bond", name: "Bond 1", price: 100, sri: 3) }
  let!(:inv1) { portfolio.investments.create!(instrument: i1, amount: 600, weight: 0.6) }
  let!(:inv2) { portfolio.investments.create!(instrument: i2, amount: 400, weight: 0.4) }

  it "transfers amount between two investments within same portfolio" do
    post "/api/v1/customers/#{customer.id}/portfolios/#{portfolio.id}/transfer", params: { from_instrument_id: i1.id, to_instrument_id: i2.id, amount: 100 }
    expect(response).to have_http_status(:no_content)
    expect(inv1.reload.amount).to eq(500)
    expect(inv2.reload.amount).to eq(500)
    expect(portfolio.reload.total_amount).to eq(1000)
  end

  it "fails on insufficient funds (422)" do
    post "/api/v1/customers/#{customer.id}/portfolios/#{portfolio.id}/transfer", params: { from_instrument_id: i1.id, to_instrument_id: i2.id, amount: 10_000 }
    expect(response).to have_http_status(:unprocessable_entity)
  end
end


