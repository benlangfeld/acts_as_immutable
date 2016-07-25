# +---------------------------------------------------------------------------+
# | Acts As Immutable                                                         |
# +---------------------------------------------------------------------------+
# | A Rails plugin that will ensure an ActiveRecord object is immutable once  |
# | saved. Optionally, you can specify attributes to be mutable if the object |
# | is in a particular state (block evaluates to true).                       |
# +---------------------------------------------------------------------------+
# | Author: NuLayer Inc. / www.nulayer.com                                    |
# +---------------------------------------------------------------------------+

module ActsAsImmutable
  def self.included(base)
    base.extend ClassMethods
    base.send :include, InstanceMethods
  end

  module InstanceMethods
    def mutable?
      cond = self.class.mutable_condition
      options = self.class.mutable_options
      (options[:new_records_mutable] && new_record?) || (cond && instance_eval(&cond))
    end

    def immutable?
      !mutable?
    end

    protected
    def validate_immutability
      changed_attrs = self.changes.keys.map(&:to_sym)
      (changed_attrs - self.class.mutable_attributes).each do |attr|
        if immutable?
          self.errors.add(attr, "is immutable")
        end
      end
    end

    def validate_immutability_destroy
      if immutable? && !self.class.included_modules.include?(DestroyedAt)
        errors.add(:base, "Record is immutable")
        false
      else
        true
      end
    end
  end

  module ClassMethods
    def self.extended(base)
      base.class_attribute :mutable_attributes
      base.class_attribute :mutable_condition
      base.class_attribute :mutable_options
    end

    def acts_as_immutable(*mutable_attributes, &condition)
      options = {:new_records_mutable => true}
      options.merge!(mutable_attributes.pop) if mutable_attributes.last.is_a?(Hash)
      self.mutable_attributes = mutable_attributes
      self.mutable_condition  = condition
      self.mutable_options    = options

      self.validate :validate_immutability
      self.before_destroy :validate_immutability_destroy
    end

    def mutable_attributes
      self.mutable_attributes || []
    end
  end
end

ActiveRecord::Base.send :include, ActsAsImmutable
