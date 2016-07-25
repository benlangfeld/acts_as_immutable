class Payment < ActiveRecord::Base
  belongs_to :account

  # mutable only when account is active
  acts_as_immutable new_records_mutable: false do
    account.active
  end
end

class Account < ActiveRecord::Base
  has_many :payments

  # mutable only when account is active
  acts_as_immutable { active }
end
