$:.unshift(File.dirname(__FILE__) + '/../')
$:.unshift(File.dirname(__FILE__) + '/../../lib')

require 'config'
require 'acts_as_immutable'
require 'ruby-debug'

class ActsAsImmutableUsingVirtualField < ActiveRecord::TestCase
  class Payment < ActiveRecord::Base
    attr_accessor :record_locked
    acts_as_immutable(:status, :amount) do
      !record_locked
    end
    
    def after_initialize
      self.record_locked = true
    end
  end

  class Payment2 < ActiveRecord::Base
    set_table_name :payments
    attr_accessor :record_locked

    acts_as_immutable do
      !record_locked
    end

    def after_initialize
      self.record_locked = true
    end
  end

  def test_is_mutable
    p = Payment.create!(:customer => "Valentin", :status => "success", :amount => 5.00)
    assert !p.mutable?
    p.record_locked = false
    assert p.mutable?
  end

  def test_is_immutable
    p = Payment.create!(:customer => "Valentin", :status => "success", :amount => 5.00)
    assert p.immutable?
    p.record_locked = false
    assert !p.immutable?
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
    assert_not_nil p.errors.on(:base)
    assert_not_nil Payment2.find_by_id(p.id)

    p.record_locked = false
    p.destroy
    assert_nil Payment2.find_by_id(p.id)

    p = Payment2.new(:customer => "Valentin", :status => "success", :amount => 5.00)
    p.destroy
  end

  private
  def assert_error_on(object, association)
    object.valid?
    assert_not_nil object.errors.on(association)
  end

  def assert_no_error_on(object, association)
    object.valid?
    assert_nil object.errors.on(association)
  end

  def assert_valid(object)
    assert object.valid?, "#{object.errors.full_messages.to_sentence}"
  end
end
