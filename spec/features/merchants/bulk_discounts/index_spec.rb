require 'rails_helper'

RSpec.describe 'the Merchant Bulk Discounts Index' do
  before :each do
    @merchants = create_list(:merchant, 3)
    @bulk_discounts_0 = create_list(:bulk_discount, 3, merchant: @merchants[0])
    @bulk_discounts_1 = create_list(:bulk_discount, 4, merchant: @merchants[1])
    visit merchant_bulk_discounts_path(@merchants[0])
  end

  describe 'as a merchant' do

    it 'shows all of my bulk discounts' do
      expect(page).to have_content("Percent Discounted:", count: 3)
      expect(page).to have_content("Quantity Threshold:", count: 3)
    end
    
    it 'shows my bulk discount percent discounted' do
      within("#discount_#{@bulk_discounts_0[0].id}") do
        expect(page).to have_content(@bulk_discounts_0[0].percentage)
      end
    end

    it 'shows my bulk discount quantity threshold' do
      within("#discount_#{@bulk_discounts_0[1].id}") do
        expect(page).to have_content(@bulk_discounts_0[1].quantity)
      end
    end
  end

  describe 'links' do
    it 'each bulk discount links to that bulk discounts show page' do
      expect(page).to have_link("View This Bulk Discount Show Page", count: 3)
    end

    it 'has a link to create a bulk discount' do
      click_link "Create Bulk Discount"
      expect(current_path).to eq(new_merchant_bulk_discount_path(@merchants[0]))
    end
  end


  

end