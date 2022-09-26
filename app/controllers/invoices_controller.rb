class InvoicesController < ApplicationController

  def index
    @merchant = Merchant.find(params[:merchant_id])
    @invoices = @merchant.merchant_invoices
  end

  def show
    @invoice = Invoice.find(params[:id])
    # @eligible_items = @invoice.invoice_items.eligible_for_discount
  end

end