require 'rails_helper'

RSpec.describe 'the Merchant Bulk Discounts Index' do
  before :each do
    @merchants = create_list(:merchant, 3)
    @bulk_discounts_0 = create_list(:bulk_discount, 3, merchant: @merchants[0])
  
  end

  it 'exists' do
    visit "/merchants/#{@merchants[0].id}/bulk_discounts"
  end

end