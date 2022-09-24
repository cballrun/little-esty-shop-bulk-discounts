require 'rails_helper'

RSpec.describe 'Merchant Bulk Discount New' do
  before :each do
    @merchant = create(:merchant)
    @merchant_bulk_discounts = create_list(:bulk_discount, 10, merchant: @merchant)
    visit new_merchant_bulk_discount_path(@merchant)
  end
  
  describe 'the merchant bulk discount new'
    it 'renders the new form' do
      expect(page).to have_content('New Bulk Discount')
      expect(find('form')).to have_content('Percentage')
      expect(find('form')).to have_content('Quantity')
    end

  describe 'the bulk discount create' do
    context 'given valid data' do
      it 'creates the bulk discount and redirects to the merchant bulk discount index page' do
        fill_in 'Percentage', with: 50
        fill_in 'Quantity', with: 20
       
        expect { click_on 'Create Bulk discount' }.to change { BulkDiscount.count }.by(1)
        expect(current_path).to eq(merchant_bulk_discounts_path(@merchant))
      end
    end

    context 'given invalid data' do
      it 'redirects to the new bulk discount page with instructions on how to fix the errors' do
        fill_in 'Percentage', with: 200
        fill_in 'Quantity', with: -200

        click_on 'Create Bulk discount'

        expect(current_path).to eq(new_merchant_bulk_discount_path(@merchant))
        expect(page).to have_content("Percentage must be less than or equal to 100")
        expect(page).to have_content("Quantity must be greater than or equal to 0")
      end

    end
  end

  
end