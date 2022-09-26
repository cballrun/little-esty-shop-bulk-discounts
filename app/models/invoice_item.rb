class InvoiceItem < ApplicationRecord
  enum status: ["Pending", "Packaged", "Shipped"]

  validates_presence_of :item_id
  validates_presence_of :invoice_id
  validates :quantity, presence: :true, numericality: { only_integer: true }
  validates :unit_price, presence: :true, numericality: { only_integer: true }
  validates_presence_of :status, inclusion: ["Pending", "Packaged", "Shipped"]

  belongs_to :item
  belongs_to :invoice
  has_one :merchant, through: :item
  has_many :bulk_discounts, through: :merchant

  def self.unshipped_invoice_items
    where.not(status: 2)
  end

  def inv_item_revenue
    self.quantity * self.unit_price
  end

  def self.invoice_items_eligible_for_discount
    joins(:bulk_discounts)
    .where("invoice_items.quantity >= bulk_discounts.quantity")
  end

  def eligible_for_discount? ###needs to be fixed
    quantity >= bulk_discounts.quantity
  end

  def best_discount
    bulk_discounts.max_by(percentage)
  end

  # def discount_amount
  #   x = self.bulk_discounts
  #   y = (x.percentage/100.to_f)
  #   z = self.inv_item_revenue * y
  #   z
  # end
end