class Instrument < ApplicationRecord
  has_many :investments, dependent: :destroy
  has_many :portfolios, through: :investments

  enum kind: {
    stock: "Action",
    bond: "Obligation",
    euro_fund: "Fonds en Euros"
  }

  validates :isin, presence: true, uniqueness: true
  validates :kind, presence: true
  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :sri, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end


