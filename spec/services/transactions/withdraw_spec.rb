require "rails_helper"

RSpec.describe Transactions::Withdraw do
  let!(:customer) { Customer.create!(first_name: "A", last_name: "B") }
  let!(:portfolio) { customer.portfolios.create!(name: "CTO", kind: "CTO", total_amount: 1000) }
  let!(:instrument) { Instrument.create!(isin: "FR0000000101", kind: "stock", name: "ETF", price: 10, sri: 5) }
  let!(:investment) { portfolio.investments.create!(instrument: instrument, amount: 200, weight: 0.2) }

  it "subtracts amount from investment and portfolio" do
    described_class.call(portfolio: portfolio, investment: investment, amount: 50)
    expect(investment.reload.amount).to eq(150)
    expect(portfolio.reload.total_amount).to eq(950)
  end

  it "rejects insufficient funds" do
    expect {
      described_class.call(portfolio: portfolio, investment: investment, amount: 500)
    }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "rejects non-positive amount" do
    expect {
      described_class.call(portfolio: portfolio, investment: investment, amount: 0)
    }.to raise_error(ActionController::ParameterMissing)
  end
end


