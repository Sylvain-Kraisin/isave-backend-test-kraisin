require "rails_helper"

RSpec.describe Eligibility do
  class DummyEligibility
    include Eligibility

    # expose the private method for testing via public wrapper
    def check!
      require_transaction_eligibility!
    end

    # stubbed by specs
    def render_error(**_args); end

    attr_accessor :portfolio
  end

  let(:dummy) { DummyEligibility.new }

  it "does nothing for CTO portfolio" do
    dummy.portfolio = double(cto?: true, pea?: false)
    expect(dummy).not_to receive(:render_error)
    dummy.check!
  end

  it "does nothing for PEA portfolio" do
    dummy.portfolio = double(cto?: false, pea?: true)
    expect(dummy).not_to receive(:render_error)
    dummy.check!
  end

  it "renders not_eligible for non-eligible portfolio" do
    dummy.portfolio = double(cto?: false, pea?: false)
    expect(dummy).to receive(:render_error).with(hash_including(status: :unprocessable_entity, code: "not_eligible"))
    dummy.check!
  end
end


