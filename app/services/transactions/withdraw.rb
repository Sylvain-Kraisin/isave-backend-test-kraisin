module Transactions
  class Withdraw
    def self.call(portfolio:, investment:, amount:)
      amount = BigDecimal(amount.to_s)
      raise ActionController::ParameterMissing, "amount must be positive" if amount <= 0
      raise ActiveRecord::RecordInvalid.new(investment), "Insufficient funds" if investment.amount < amount
      
      ApplicationRecord.transaction do
        investment.update!(amount: investment.amount - amount)
        portfolio.update!(total_amount: portfolio.total_amount - amount)
      end
      
      true
    end
  end
end


