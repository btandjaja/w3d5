require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options
  def self.my_attr_accessor
    p self
    # define_method()
  end

  def has_one_through(name, through_name, source_name)
    # ...
  end
end
