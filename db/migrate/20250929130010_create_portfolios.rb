class CreatePortfolios < ActiveRecord::Migration[7.1]
  def change
    create_table :portfolios do |t|
      t.references :customer, null: false, foreign_key: true
      t.string :name, null: false
      t.string :kind, null: false
      t.decimal :total_amount, precision: 15, scale: 2, null: false, default: 0
      t.timestamps
    end

    add_index :portfolios, :kind
  end
end



