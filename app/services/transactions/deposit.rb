module Transactions
  class Deposit
    def self.call(portfolio:, investment:, amount:)
      amount = BigDecimal(amount.to_s)
      raise ActionController::ParameterMissing, "amount must be positive" if amount <= 0
      
      ApplicationRecord.transaction do
        investment.update!(amount: investment.amount + amount)
        portfolio.update!(total_amount: portfolio.total_amount + amount)
      end
      
      true
    end
  end
end


