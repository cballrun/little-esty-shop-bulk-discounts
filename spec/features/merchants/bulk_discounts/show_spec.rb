require 'rails_helper'

RSpec.describe 'the Merchant Bulk Discounts Index' do
  before :each do
    @merchants = create_list(:merchant, 3)
    @bulk_discounts_0 = create_list(:bulk_discount, 3, merchant: @merchants[0])
    @bulk_discounts_1 = create_list(:bulk_discount, 4, merchant: @merchants[1])
    visit merchant_bulk_discounts_path(@merchants[0])
  end