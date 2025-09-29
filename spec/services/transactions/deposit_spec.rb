require "rails_helper"

RSpec.describe Transactions::Deposit do
  let!(:customer) { Customer.create!(first_name: "A", last_name: "B") }
  let!(:portfolio) { customer.portfolios.create!(name: "CTO", kind: "CTO", total_amount: 1000) }
  let!(:instrument) { Instrument.create!(isin: "FR0000000100", kind: "stock", name: "ETF", price: 10, sri: 5) }
  let!(:investment) { portfolio.investments.create!(instrument: instrument, amount: 100, weight: 0.1) }

  it "adds amount to investment and portfolio" do
    described_class.call(portfolio: portfolio, investment: investment, amount: 50)
    expect(investment.reload.amount).to eq(150)
    expect(portfolio.reload.total_amount).to eq(1050)
  end

  it "rejects non-positive amount" do
    expect {
      described_class.call(portfolio: portfolio, investment: investment, amount: 0)
    }.to raise_error(ActionController::ParameterMissing)
  end
end


