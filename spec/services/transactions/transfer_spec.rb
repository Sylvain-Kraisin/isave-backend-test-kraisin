require "rails_helper"

RSpec.describe Transactions::Transfer do
  let!(:customer) { Customer.create!(first_name: "A", last_name: "B") }
  let!(:portfolio) { customer.portfolios.create!(name: "PEA", kind: "PEA", total_amount: 1000) }
  let!(:i1) { Instrument.create!(isin: "FR0000000201", kind: "stock", name: "ETF1", price: 10, sri: 5) }
  let!(:i2) { Instrument.create!(isin: "FR0000000202", kind: "bond", name: "B1", price: 10, sri: 2) }
  let!(:inv1) { portfolio.investments.create!(instrument: i1, amount: 600, weight: 0.6) }
  let!(:inv2) { portfolio.investments.create!(instrument: i2, amount: 400, weight: 0.4) }

  it "moves funds between investments without changing portfolio total" do
    described_class.call(portfolio: portfolio, from_investment: inv1, to_investment: inv2, amount: 100)
    expect(inv1.reload.amount).to eq(500)
    expect(inv2.reload.amount).to eq(500)
    expect(portfolio.reload.total_amount).to eq(1000)
  end

  it "rejects insufficient funds" do
    expect {
      described_class.call(portfolio: portfolio, from_investment: inv1, to_investment: inv2, amount: 10_000)
    }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "rejects non-positive amount" do
    expect {
      described_class.call(portfolio: portfolio, from_investment: inv1, to_investment: inv2, amount: 0)
    }.to raise_error(ActionController::ParameterMissing)
  end
end


