class BulkDiscountsController < ApplicationController
  def index
    @merchant = Merchant.find(params[:merchant_id])
    @holiday_info = HolidayFacade.get_holiday_data
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

  def destroy
    merchant = Merchant.find(params[:merchant_id])
    BulkDiscount.find(params[:id]).destroy
    redirect_to merchant_bulk_discounts_path(merchant)
  end

  def edit
    @merchant = Merchant.find(params[:merchant_id])
    @bulk_discount = BulkDiscount.find(params[:id])
  end

  def update
    bulk_discount = BulkDiscount.find(params[:id])
    if bulk_discount.update(bulk_discount_params)
      redirect_to merchant_bulk_discount_path(bulk_discount.merchant)
    else
      redirect_to edit_merchant_bulk_discount_path(bulk_discount.merchant)
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