class CreateInvestments < ActiveRecord::Migration[7.1]
  def change
    create_table :investments do |t|
      t.references :portfolio, null: false, foreign_key: true
      t.references :instrument, null: false, foreign_key: true
      t.decimal :amount, precision: 15, scale: 2, null: false
      t.decimal :weight, precision: 8, scale: 4, null: false
      t.timestamps
    end

    add_index :investments, [:portfolio_id, :instrument_id], unique: true
  end
end



