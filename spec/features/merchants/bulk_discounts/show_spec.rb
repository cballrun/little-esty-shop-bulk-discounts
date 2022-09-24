require 'rails_helper'

RSpec.describe 'the Merchant Bulk Discounts Show Page' do
  before :each do
    @merchants = create_list(:merchant, 3)
    @bulk_discounts_0 = create_list(:bulk_discount, 3, merchant: @merchants[0])
    @bulk_discounts_1 = create_list(:bulk_discount, 4, merchant: @merchants[1])
    visit "merchants/#{@merchants[0].id}/bulk_discounts/#{@bulk_discounts_0[0].id}"
  end

  describe 'as a merchant' do
    it 'shows my bulk discounts quantity threshold' do
      expect(page).to have_content(@bulk_discounts_0[0].quantity)
    end

    it 'shows my bulk discounts percentage discount' do
      expect(page).to have_content(@bulk_discounts_0[0].percentage)
    end
  end

end