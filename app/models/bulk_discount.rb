class BulkDiscount < ApplicationRecord
  belongs_to :merchant
  validates_presence_of :percentage, :quantity
  validates_numericality_of :percentage, only_integer: true, greater_than: 0, less_than_or_equal_to: 100
  validates_numericality_of :quantity, only_integer: true, greater_than_or_equal_to: 0

end