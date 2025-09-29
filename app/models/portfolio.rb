class Portfolio < ApplicationRecord
  belongs_to :customer
  has_many :investments, dependent: :destroy
  has_many :instruments, through: :investments

  enum kind: {
    cto: "CTO",
    pea: "PEA",
    assurance_vie: "Assurance Vie",
    livret_a: "Livret A"
  }

  validates :name, presence: true
  validates :kind, presence: true
  validates :total_amount, numericality: { greater_than_or_equal_to: 0 }

  def allows_investments?
    cto? || pea? || assurance_vie?
  end
end


