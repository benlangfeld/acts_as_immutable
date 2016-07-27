class Payment < ActiveRecord::Base
  belongs_to :account

  acts_as_immutable new_records_mutable: false, if: ->{ account.read_only? }
end

class Account < ActiveRecord::Base
  has_many :payments

  acts_as_immutable if: :read_only?

  def read_only?
    !active && !active_changed?
  end
end
