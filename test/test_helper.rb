# require 'rails'
# require 'rails/test_help'
require 'active_record'
require 'minitest/autorun'

$: << 'lib'

require 'acts_as_immutable'

ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: ":memory:")

silence_stream(STDOUT) do
  ActiveRecord::Schema.define do
    create_table :payments, :force => true do |t|
      t.string :customer
      t.decimal :amount
      t.string :status
    end
  end
end
