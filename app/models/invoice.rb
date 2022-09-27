class Invoice < ApplicationRecord
  enum status: ["In Progress", "Completed", "Cancelled"]

  validates_presence_of :status, inclusion: ["In Progress", "Completed", "Cancelled"]
  validates_presence_of :customer_id

  belongs_to :customer
  has_many :transactions
  has_many :invoice_items
  has_many :items, through: :invoice_items
  has_many :merchants, through: :items
  has_many :bulk_discounts, through: :merchants


  def find_invoice_item_quantity(invoice, item)
    InvoiceItem.find_by(invoice: invoice, item: item).quantity
  end

  def find_invoice_item_status(invoice, item)
    InvoiceItem.find_by(invoice: invoice, item: item).status
  end

  def total_revenue
    items.
    joins(:invoice_items).
    sum('invoice_items.quantity * invoice_items.unit_price')
  end

  def self.incomplete_invoices_sorted
     joins(:invoice_items)
    .distinct
    .where.not("invoice_items.status = ?", 2)
    .order(:created_at)
  end

  def total_invoice_revenue_for_merchant(merchant_id)
    items
    .joins(:invoice_items)
    .where("items.merchant_id = ?", merchant_id)
    .sum("invoice_items.unit_price * invoice_items.quantity")
  end

  def total_best_discount_amount_for_merchant(merchant_id)
    invoice_items
    .joins(:bulk_discounts)
    .where("invoice_items.quantity >= bulk_discounts.quantity AND bulk_discounts.merchant_id = ?", merchant_id)
    .select("invoice_items.*, max(invoice_items.quantity *invoice_items.unit_price * (bulk_discounts.percentage/100.00)) as discount_amount")
    .group(:id)
    .sum(&:discount_amount)
  end

  def total_discounted_revenue_for_merchant(merchant_id)
    total_invoice_revenue_for_merchant(merchant_id) - total_best_discount_amount_for_merchant(merchant_id)
  end


  def discount_amount
     invoice_items
    .joins(:bulk_discounts)
    .where("invoice_items.quantity >= bulk_discounts.quantity")
    .select("invoice_items.*, max(invoice_items.quantity *invoice_items.unit_price * (bulk_discounts.percentage/100.00)) as discount_amount")
    .group(:id)
    .sum(&:discount_amount)
  end

  def discounted_revenue
    total_revenue - discount_amount
  end

  def total_invoice_revenue_dollars 
    total_revenue.to_f / 100
  end
end