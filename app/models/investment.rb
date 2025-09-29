class Investment < ApplicationRecord
  belongs_to :portfolio
  belongs_to :instrument
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :weight, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }
  validates :instrument_id, uniqueness: { scope: :portfolio_id }
  validate :portfolio_kind_must_allow_investments

  private

  def portfolio_kind_must_allow_investments
    return if portfolio.nil?
    return if portfolio.allows_investments?

    errors.add(:portfolio, "kind does not allow investments")
  end
end


