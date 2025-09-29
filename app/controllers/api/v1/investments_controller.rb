module Api
  module V1
    class InvestmentsController < ApplicationController
      include Eligibility
      before_action :load_resources
      before_action :require_transaction_eligibility!

      def deposit
        with_amount do |amount|
          Transactions::Deposit.call(portfolio: @portfolio, investment: @investment, amount: amount)
        end
      end

      def withdraw
        with_amount do |amount|
          Transactions::Withdraw.call(portfolio: @portfolio, investment: @investment, amount: amount)
        end
      end

      private

      def load_resources
        @customer = Customer.find(params[:customer_id])
        @portfolio = @customer.portfolios.find(params[:portfolio_id])
        @investment = @portfolio.investments.find_by!(instrument_id: params[:id])
      end

      def with_amount
        amount = params.require(:amount)
        yield(amount)
        head :no_content
      end
    end
  end
end


