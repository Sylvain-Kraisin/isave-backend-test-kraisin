module Api
  module V1
    class PortfoliosController < ApplicationController
      def index
        customer = Customer.find(params[:customer_id])

        render json: { contracts: serialize_contracts(customer) }
      end

      private

      def serialize_contracts(customer)
        customer.portfolios.includes(investments: :instrument).map do |portfolio|
          {
            label: portfolio.name,
            type: Portfolio.kinds[portfolio.kind],
            amount: portfolio.total_amount.to_f,
            lines: portfolio.investments.map do |inv|
              instrument = inv.instrument
              {
                type: instrument.kind,
                isin: instrument.isin,
                label: instrument.name,
                price: instrument.price.to_f,
                share: inv.weight.to_f,
                amount: inv.amount.to_f,
                srri: instrument.sri
              }
            end
          }.tap do |hash|
            hash.delete(:lines) if portfolio.investments.empty?
          end
        end
      end
    end
  end
end


