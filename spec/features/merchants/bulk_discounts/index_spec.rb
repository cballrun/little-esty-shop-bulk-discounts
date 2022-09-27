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
      within("#discount_#{@bulk_discounts_0[0].id}") do
        click_link "View This Bulk Discount Show Page"
        expect(current_path).to eq(merchant_bulk_discount_path(@merchants[0], @bulk_discounts_0[0]))
      end
    end

    it 'has a link to create a bulk discount' do
      click_link "Create Bulk Discount"
      expect(current_path).to eq(new_merchant_bulk_discount_path(@merchants[0]))
    end

    it 'each bulk discount has a link to delete this bulk discount' do
      expect(page).to have_link("Delete This Bulk Discount", count: 3)
    end

    it 'clicking the link deletes a bulk discount' do
      within("#discount_#{@bulk_discounts_0[0].id}") do
        expect(@merchants[0].bulk_discounts.count).to eq(3)
        click_link "Delete This Bulk Discount"
        expect(@merchants[0].bulk_discounts.count).to eq(2)
        expect(current_path).to eq(merchant_bulk_discounts_path(@merchants[0]))
      end
    end
  end

  describe 'upcoming holidays section' do
    it 'shows the names of the next 3 upcoming holidays' do
      within("#upcoming_holidays") do
        expect(page).to have_content("Name", count: 3)
      end
    end

    it 'shows the date of the next 3 upcoming holidays' do
      within("#upcoming_holidays") do
        expect(page).to have_content("Date", count: 3)
      end
    end

    it 'shows the next 3 holidays in calendar order' do
      within("#upcoming_holidays") do
        expect("Columbus Day").to appear_before("Veterans Day")
        expect("Thanksgiving Day").to_not appear_before("Veterans Day")
      end
    end
  end
end