require 'rails_helper'

RSpec.describe 'Merchant Bulk Discount Update' do
  before :each do
    @merchant = create(:merchant)
    @merchant_bulk_discounts = create_list(:bulk_discount, 10, merchant: @merchant)
    visit edit_merchant_bulk_discount_path(@merchant, @merchant_bulk_discounts[0])
  end
  
  describe 'the merchant bulk discount edit form' do
    it 'renders the new form' do
      expect(page).to have_content('Bulk Discount Edit')
      expect(find('form')).to have_content('Percentage')
      expect(find('form')).to have_content('Quantity')
    end

    it 'has the correct prepopulated values in the new form' do
      expect(find('form')).to have_field('Quantity', with: "#{@merchant_bulk_discounts[0].quantity}")
      expect(find('form')).to have_field('Percentage', with: "#{@merchant_bulk_discounts[0].percentage}")
    end
  end

  describe 'the merchant bulk discount update' do
    context 'given valid data' do
      it 'updates the bulk discount and redirects to the bulk discount show page' do
        fill_in 'Percentage', with: 88
        fill_in 'Quantity', with: 66
        click_on 'Save'

        expect(current_path).to eq(merchant_bulk_discount_path(@merchant, @merchant_bulk_discounts[0]))
        expect(page).to have_content("Discount Percentage: 88")
        expect(page).to have_content("Quantity Threshold: 66")
      end
    end

    context 'given invalid data' do
      it 'flashes error message and redirects to the edit bulk discount page' do
        fill_in 'Percentage', with: 101
        fill_in 'Quantity', with: -8
        click_on 'Save'

        expect(current_path).to eq(edit_merchant_bulk_discount_path(@merchant, @merchant_bulk_discounts[0]))
        expect(page).to have_content("Percentage must be less than or equal to 100")
        expect(page).to have_content("Quantity must be greater than or equal to 0")
      end
    end
  end
end
