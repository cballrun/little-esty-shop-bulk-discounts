require 'rails_helper'

RSpec.describe 'The Admin Invoice Show' do
  before :each do
    @merchant = create(:merchant)
    @discount = create(:bulk_discount, percentage: 10, quantity: 2, merchant: @merchant)
    @invoices = create_list(:invoice, 20)

    @inv_items_0 = create_list(:invoice_item, 5, invoice: @invoices[0])
    @inv_items_1 = create_list(:invoice_item, 5, invoice: @invoices[1])
    @inv_items_2 = create_list(:invoice_item, 5, invoice: @invoices[2])
    visit admin_invoice_path(@invoices[0])
    
    @inv_extra = create(:invoice)
    
    @inv_extra_inv_item_1 = create(:invoice_item, unit_price: 500, invoice: @inv_extra, quantity: 3, merchant: @merchant)
    @inv_extra_inv_item_2 = create(:invoice_item, unit_price: 1000, invoice: @inv_extra, quantity: 2, merchant: @merchant)
    @inv_extra_inv_item_3 = create(:invoice_item, unit_price: 2000, invoice: @inv_extra, quantity: 1, merchant: @merchant)
  end
  
  describe 'invoice info section' do
    it 'shows the invoice ID' do
      within("#invoice_info") do
        @invoices.each do |inv|
          visit admin_invoice_path(inv)
          expect(page).to have_content(inv.id)
        end
      end
    end

    it 'shows the invoice status' do
      within("#invoice_info") do
        @invoices.each do |inv|
          visit admin_invoice_path(inv)
          expect(page).to have_content(inv.status)
        end
      end
    end

    it 'shows the invoices created at date in the correct format' do
      within("#invoice_info") do
        @invoices.each do |inv|
          visit admin_invoice_path(inv)
          expect(page).to have_content(inv.created_at.strftime("%A, %B %d, %Y"))
        end
      end
    end

    it 'shows the invoice customers first and last name' do
      within("#invoice_info") do
        @invoices.each do |inv|
          visit admin_invoice_path(inv)
          expect(page).to have_content(inv.customer.first_name)
          expect(page).to have_content(inv.customer.last_name)
        end
      end
    end
  

    it 'shows the total revenue in dollars' do
      visit admin_invoice_path(@inv_extra)
      within("#invoice_info") do
        expect(page).to have_content("Total Revenue: $55.00")
      end
    end


    it 'shows the discounted in dollars' do
      visit admin_invoice_path(@inv_extra)
      within("#invoice_info") do
        expect(page).to have_content("Discounted Revenue: $51.50")
      end
    end
  end


  describe 'invoice item information section' do
    it 'shows all item names' do
      within("#all_invoice_items") do
        @inv_items_0.each do |ii|
          within("#inv_item_#{ii.id}") do
            expect(page).to have_content(ii.item.name)
            expect(page).to_not have_content(@inv_items_1[0].item.name)
          end
        end
      end
    end

    it 'shows all invoice item quantities' do
      visit admin_invoice_path(@invoices[1])
      within("#all_invoice_items") do
        @inv_items_1.each do |ii|
          within("#inv_item_#{ii.id}") do
            expect(page).to have_content(ii.quantity)
          end
        end
      end
    end

    it 'shows all invoice item prices' do
      visit admin_invoice_path(@invoices[2])
      within("#all_invoice_items") do
        @inv_items_2.each do |ii|
          within("#inv_item_#{ii.id}") do
            expect(page).to have_content(ii.item.current_price)
            expect(page).to_not have_content(@inv_items_0[3].unit_price)
          end
        end
      end
    end

    it 'shows all invoice item statuses' do
      visit admin_invoice_path(@invoices[2])
      within("#all_invoice_items") do
        @inv_items_2.each do |ii|
          within("#inv_item_#{ii.id}") do
            expect(page).to have_content(ii.status)
          end
        end
      end
    end
  end

  describe 'update invoice status' do

    it 'changes a status to In Progress' do
      within("#invoice_info") do
        comp_invoice = create(:invoice, status: 1)
        canc_invoice = create(:invoice, status: 2)

        visit admin_invoice_path(comp_invoice.id)

        expect(page).to have_content("Status: Completed")

        select("In Progress")
        click_button 'Submit'

        expect(current_path).to eq(admin_invoice_path(comp_invoice.id))
        expect(page).to have_content("Status: In Progress")
        expect(page).to_not have_content("Status: Completed")
      end
    end

    it 'changes a status to Completed' do
      within("#invoice_info") do
        ip_invoice = create(:invoice, status: 0)
        canc_invoice = create(:invoice, status: 2)

        visit admin_invoice_path(ip_invoice.id)
        
        expect(page).to have_content("Status: In Progress")
        
        select("Completed")
        click_button 'Submit'

        expect(current_path).to eq(admin_invoice_path(ip_invoice.id))
        expect(page).to have_content("Status: Completed")
      end
    end

    it 'changes a status to Cancelled' do
      within("#invoice_info") do
        ip_invoice = create(:invoice, status: 0)
        comp_invoice = create(:invoice, status: 1)

        visit admin_invoice_path(comp_invoice.id)
        

        expect(page).to have_content("Status: Completed")

        select("Cancelled")
        click_button 'Submit'

        expect(current_path).to eq(admin_invoice_path(comp_invoice.id))
        expect(page).to have_content("Status: Cancelled")
        expect(page).to_not have_content("Status: Completed")
      end
    end

    it 'button defaults to the invoice status' do
      within("#invoice_info") do
        ip_invoice = create(:invoice, status: 0)
        visit admin_invoice_path(ip_invoice.id)

        expect(page).to have_content("Status: In Progress")
        
        click_button 'Submit'

        expect(current_path).to eq(admin_invoice_path(ip_invoice.id))
        expect(page).to have_content("Status: In Progress")
      end
    end
  end
end