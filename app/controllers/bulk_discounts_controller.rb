class BulkDiscountsController < ApplicationController
  def index
    @merchant = Merchant.find(params[:merchant_id])
  end

  def show
    @bulk_discount = BulkDiscount.find(params[:id])
  end

  def new
    @merchant = Merchant.find(params[:merchant_id])
    @bulk_discount = BulkDiscount.new
  end

  def create
    merchant = Merchant.find(params[:merchant_id])
    bulk_discount = merchant.bulk_discounts.new(model_bulk_discount_params)
    if bulk_discount.save
      redirect_to merchant_bulk_discounts_path(merchant)
    else
      redirect_to new_merchant_bulk_discount_path(merchant)
      flash[:alert] = "Error: #{error_message(bulk_discount.errors)}"
    end
  end


private

  def model_bulk_discount_params
    params.require(:bulk_discount).permit(:percentage, :quantity)
  end

  def bulk_discount_params
    params.permit(:percentage, :quantity)
  end

end