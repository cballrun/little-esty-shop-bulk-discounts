require 'rails_helper'

RSpec.describe 'Merchant Bulk Discount Update' do
  before :each do
    @merchant = create(:merchant)
    @merchant_bulk_discounts = create_list(:bulk_discount, 10, merchant: @merchant)
    visit edit_merchant_bulk_discount_path(@merchant, @merchant_bulk_discounts[0])
  end
  
  describe 'the merchant bulk discount edit form' do
    xit 'renders the new form with prepopulated values' do
      expect(page).to have_content('Edit Bulk Discount')
      expect(find('form')).to have_content('Percentage')
      expect(find('form')).to have_content('Quantity')
    end

  end
end
