require 'rails_helper'

RSpec.describe 'admin dashboard' do
  before :each do
    @customers = create_list(:customer, 8)
      
    @inv_0 = create(:invoice, customer: @customers[0], status: 1)
    @transacts_0 = create_list(:transaction, 15, invoice: @inv_0, result: 0)
    @unsuc_transacts_0 = create_list(:transaction, 2, invoice: @inv_0, result: 1)

    @inv_1 = create(:invoice, customer: @customers[1], status: 1)
    @transacts_1 = create_list(:transaction, 14, invoice: @inv_1, result: 0)

    @inv_2 = create(:invoice, customer: @customers[2], status: 1)
    @transacts_2 = create_list(:transaction, 13, invoice: @inv_2, result: 0)

    @inv_3 = create(:invoice, customer: @customers[3], status: 1)
    @transacts_3 = create_list(:transaction, 12, invoice: @inv_3, result: 0)

    @inv_4 = create(:invoice, customer: @customers[4], status: 1)
    @transacts_4 = create_list(:transaction, 11, invoice: @inv_4, result: 0)

    @inv_5 = create(:invoice, customer: @customers[5], status: 1)
    transacts_5 = create_list(:transaction, 10, invoice: @inv_5, result: 0)

    @inv_6 = create(:invoice, customer: @customers[6], status: 1)
    @transacts_6 = create_list(:transaction, 9, invoice: @inv_6, result: 0)
    @unsuc_transacts_6 = create_list(:transaction, 9, invoice: @inv_6, result: 1)

    @inv_7 = create(:invoice, customer: @customers[7], status: 1)
    @transacts_7 = create_list(:transaction, 8, invoice: @inv_7, result: 0)
    @unsuc_transacts_7 = create_list(:transaction, 8, invoice: @inv_7, result: 1)

    @invoices = create_list(:invoice, 5)
    @inv_8 = create(:invoice, created_at: Date.tomorrow)
        
    @inv_items_0_shipped = create_list(:invoice_item, 5, invoice: @invoices[0], status: 2)
   
    @inv_items_1_shipped = create_list(:invoice_item, 5, invoice: @invoices[1], status: 2) 
    @inv_items_1_pending= create_list(:invoice_item, 2, invoice: @invoices[1], status: 0)
    @inv_items_1_packaged = create_list(:invoice_item, 2, invoice: @invoices[1], status: 1)

    @inv_items_2_shipped = create_list(:invoice_item, 5, invoice: @invoices[2], status: 2)

    @inv_items_3_pending = create_list(:invoice_item, 5, invoice: @invoices[3], status: 0) 

    @inv_items_4_packaged = create_list(:invoice_item, 5, invoice: @invoices[4], status: 1)

    @inv_item_8_pending = create(:invoice_item, invoice: @inv_8, status: 0)
    
    visit '/admin'
  end
  
  describe 'as an admin visiting'
    it 'has as a header indicating I am on admin dashboard' do
      expect(page).to have_content("Admin Dashboard")
    end

  describe 'top 5 customers section' do
    it 'exists' do
      within("#favorite_customers") do
        expect(page).to have_content("Top 5 Customers Overall")
      end
    end

    it 'has the names of the top 5 customers by successful transaction count' do
      within("#favorite_customers") do
        expect(page).to have_content(@customers[0].first_name)
        expect(page).to have_content(@customers[0].last_name)
        
        expect(page).to_not have_content(@customers[5].first_name)
        expect(page).to_not have_content(@customers[5].last_name)
      end
    end

    it 'has the transaction count for the top 5 customers' do
      within("#cust_#{@customers[0].id}") do
        expect(page).to have_content(@customers[0].invoices[0].transactions.where(result: 0).count)
        
        expect(page).to_not have_content(@customers[1].invoices[0].transactions.where(result: 0).count)
      end
      within("#cust_#{@customers[3].id}") do
        expect(page).to have_content(@customers[3].invoices[0].transactions.where(result: 0).count)

        expect(page).to_not have_content(@customers[0].invoices[0].transactions.where(result: 0).count)
      end
    end
  end

  describe 'incomplete invoices section'
    it 'exists' do
      within("#incomplete_invoices") do
        expect(page).to have_content("Incomplete Invoices")
      end
    end

    it 'includes the ids of all invoices that have unshipped invoice items' do
      within("#incomplete_invoices") do
        expect(page).to have_content(@invoices[1].id)
        expect(page).to have_content(@invoices[3].id)
        
        expect(page).to_not have_content(@invoices[0].id)
      end
    end

    it 'includes the properly formatted date of all invoices that have unshipped invoice items' do
      within("#incomplete_invoices") do
        todays_date = @invoices[0].created_at.strftime("%A, %B %d, %Y")
        tomorrow_date = @inv_8.created_at.strftime("%A, %B %d, %Y")

        expect(page).to have_content(todays_date)
        expect(page).to have_content(tomorrow_date)
      end
    end

    it 'each invoice id links to the invoices admin invoice show page' do
      within("#incomplete_invoices") do
        expect(page).to have_link("#{@invoices[1].id}")
        expect(page).to have_link("#{@invoices[3].id}")
        expect(page).to_not have_link("#{@invoices[0].id}")

        click_link("#{@invoices[1].id}")
        expect(current_path).to eq(admin_invoice_path(@invoices[1].id))
      end
    end

  describe 'links' do
    
    it 'has a link to the Admin Merchant Index' do
      within("#global_links") do
        click_link("Merchant Index")
        expect(current_path).to eq(admin_merchants_path)
    end
  end

    it 'has a link to the Admin Invoice Index' do
      within("#global_links") do
        click_link("Invoice Index")
        expect(current_path).to eq(admin_invoices_path)
      end
    end
  end
end