require "json"

Investment.destroy_all
Instrument.destroy_all
Portfolio.destroy_all
Customer.destroy_all

customer = Customer.create!(first_name: "Sample", last_name: "Customer")

file_path = Rails.root.join("data", "level_1", "portfolios.json")
data = JSON.parse(File.read(file_path))

data.fetch("contracts", []).each do |contract|
  kind = contract.fetch("type")
  unless Portfolio.kinds.values.include?(kind)
    Rails.logger.info("Skipping portfolio with unsupported kind: #{kind} (#{contract.fetch("label")})")
    next
  end

  portfolio = customer.portfolios.create!(
    name: contract.fetch("label"),
    kind: kind,
    total_amount: contract.fetch("amount", 0)
  )

  (contract["lines"] || []).each do |line|
    instrument = Instrument.find_or_initialize_by(isin: line.fetch("isin"))
    instrument.kind = line.fetch("type")
    instrument.name = line.fetch("label")
    instrument.price = line.fetch("price")
    instrument.sri = line.fetch("srri")
    instrument.save!

    portfolio.investments.create!(
      instrument: instrument,
      amount: line.fetch("amount"),
      weight: line.fetch("share")
    )
  end
end

puts "Seeded: #{Customer.count} customers, #{Portfolio.count} portfolios, #{Instrument.count} instruments, #{Investment.count} investments"
# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
