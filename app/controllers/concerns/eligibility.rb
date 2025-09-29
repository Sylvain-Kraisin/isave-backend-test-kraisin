module Eligibility
  extend ActiveSupport::Concern

  private

  def require_transaction_eligibility!
    return unless defined?(@portfolio) && @portfolio.present?
    
    unless @portfolio.cto? || @portfolio.pea?
      render_error(status: :unprocessable_entity, code: "not_eligible", message: "Portfolio is not eligible for transactions")
    end
  end
end


