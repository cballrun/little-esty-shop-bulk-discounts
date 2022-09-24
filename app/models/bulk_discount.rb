class BulkDiscount < ApplicationRecord
  belongs_to :merchant
  has_many :items, through: :merchant
  has_many :invoice_items, through: :items
  has_many :invoices, through: :invoice_items
  validates_presence_of :percentage, :quantity
  validates_numericality_of :percentage, only_integer: true, greater_than: 0, less_than_or_equal_to: 100
  validates_numericality_of :quantity, only_integer: true, greater_than_or_equal_to: 0

end