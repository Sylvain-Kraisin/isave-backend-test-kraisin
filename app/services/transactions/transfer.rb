module Transactions
  class Transfer
    def self.call(portfolio:, from_investment:, to_investment:, amount:)
      amount = BigDecimal(amount.to_s)
      raise ActionController::ParameterMissing, "amount must be positive" if amount <= 0
      raise ActiveRecord::RecordInvalid.new(from_investment), "Insufficient funds" if from_investment.amount < amount
      
      ApplicationRecord.transaction do
        from_investment.update!(amount: from_investment.amount - amount)
        to_investment.update!(amount: to_investment.amount + amount)
      end
      
      true
    end
  end
end


