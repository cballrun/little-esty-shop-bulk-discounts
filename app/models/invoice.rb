class Invoice < ApplicationRecord
  enum status: ["In Progress", "Completed", "Cancelled"]

  validates_presence_of :status, inclusion: ["In Progress", "Completed", "Cancelled"]
  validates_presence_of :customer_id

  belongs_to :customer
  has_many :transactions
  has_many :invoice_items
  has_many :items, through: :invoice_items

  def self.incomplete_invoices
    where(status: 0)
  end
end