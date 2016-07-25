ActiveRecord::Schema.define do
  create_table :payments, force: true do |t|
    t.integer :account_id, null: false
    t.decimal :amount, null: false
  end

  create_table :accounts, force: true do |t|
    t.integer :number, null: false
    t.string  :customer, null: false
    t.boolean :active, null: false, default: true
  end
end
