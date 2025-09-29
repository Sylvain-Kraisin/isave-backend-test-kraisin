class CreateInstruments < ActiveRecord::Migration[7.1]
  def change
    create_table :instruments do |t|
      t.string :isin, null: false
      t.string :kind, null: false
      t.string :name, null: false
      t.decimal :price, precision: 15, scale: 2, null: false
      t.integer :sri, null: false
      t.timestamps
    end

    add_index :instruments, :isin, unique: true
    add_index :instruments, :kind
  end
end



