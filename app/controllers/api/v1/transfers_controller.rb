module Api
  module V1
    class TransfersController < ApplicationController
      include Eligibility
      before_action :load_resources
      before_action :require_transaction_eligibility!

      def create
        with_transfer_params do |from_id, to_id, amount|
          from_inv = @portfolio.investments.find_by!(instrument_id: from_id)
          to_inv = @portfolio.investments.find_by!(instrument_id: to_id)
          Transactions::Transfer.call(portfolio: @portfolio, from_investment: from_inv, to_investment: to_inv, amount: amount)
        end
      end

      private

      def load_resources
        @customer = Customer.find(params[:customer_id])
        @portfolio = @customer.portfolios.find(params[:portfolio_id])
      end

      def with_transfer_params
        from_id = params.require(:from_instrument_id).to_i
        to_id = params.require(:to_instrument_id).to_i
        return render_error(status: :bad_request, code: "bad_request", message: "from and to must differ") if from_id == to_id
        amount = params.require(:amount)
        yield(from_id, to_id, amount)
        head :no_content
      end
    end
  end
end


