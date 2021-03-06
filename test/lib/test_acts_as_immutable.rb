require 'test_helper'

class ActsAsImmutableUsingVirtualField < MiniTest::Test
  class Payment < ActiveRecord::Base
    attr_accessor :record_locked

    after_initialize :lock

    acts_as_immutable(:status, :amount) do
      !record_locked
    end

    def lock
      self.record_locked = true
    end
  end

  class Payment2 < ActiveRecord::Base
    self.table_name = :payments

    attr_accessor :record_locked

    after_initialize :lock

    acts_as_immutable do
      !record_locked
    end

    def lock
      self.record_locked = true
    end
  end

  class PaymentLockOnNew < ActiveRecord::Base
    self.table_name = :payments

    attr_accessor :record_locked

    after_initialize :lock

    acts_as_immutable :new_records_mutable => false do
      !record_locked
    end

    def lock
      self.record_locked = true
    end
  end

  def test_is_mutable
    p = Payment.create!(:customer => "Valentin", :status => "success", :amount => 5.00)
    refute p.mutable?
    p.record_locked = false
    assert p.mutable?
  end

  def test_is_immutable
    p = Payment.create!(:customer => "Valentin", :status => "success", :amount => 5.00)
    assert p.immutable?
    p.record_locked = false
    refute p.immutable?
  end

  def test_writing_attributes_without_white_list
    p = Payment2.create!(:customer => "Valentin", :status => "success", :amount => 5.00)
    p.customer = 'test'
    assert_error_on p, :customer

    p.record_locked = false
    assert_no_error_on p, :customer
  end

  def test_writing_mutable_attributes
    p = Payment.create!(:customer => "Valentin", :status => "success", :amount => 5.00)
    p.status = 'fail'
    assert_valid p
  end

  def test_destroy
    p = Payment2.create!(:customer => "Valentin", :status => "success", :amount => 5.00)
    assert_valid p
    p.destroy
    assert_not_nil p.errors.get(:base)
    assert_not_nil Payment2.find_by_id(p.id)

    p.record_locked = false
    p.destroy
    assert_nil Payment2.find_by_id(p.id)

    p = Payment2.new(:customer => "Valentin", :status => "success", :amount => 5.00)
    p.destroy
  end

  def test_new_records_should_be_mutable
    assert Payment.new.mutable?
  end

  def test_new_records_with_lock_on_new_should_not_be_mutable
    refute PaymentLockOnNew.new.mutable?
    p = PaymentLockOnNew.new(:customer => "Valentin", :status => "success", :amount => 5.00)
    refute p.valid?
  end

  def test_new_records_with_lock_on_new_should_be_mutable_if_condition_is_met
    p = PaymentLockOnNew.new
    p.record_locked = false
    assert p.mutable?
  end

private

  def assert_error_on(object, association)
    object.valid?
    assert_not_nil object.errors.get(association)
  end

  def assert_no_error_on(object, association)
    object.valid?
    assert_nil object.errors.get(association)
  end

  def assert_valid(object)
    assert object.valid?, "#{object.errors.full_messages.to_sentence}"
  end

  def assert_not_nil(exp, msg = nil)
    msg = message(msg) { "<#{mu_pp(exp)}> expected to not be nil" }
    refute exp.nil?, msg
  end
end
