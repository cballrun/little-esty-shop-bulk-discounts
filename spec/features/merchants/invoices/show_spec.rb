require 'rails_helper'

RSpec.describe 'Invoice Show Page' do
  describe 'invoice attributes' do

    before :each do
      @merchant = create(:merchant)
      @merchant2 = create(:merchant)
      @bulk_discount = create(:bulk_discount, merchant: @merchant, percentage: 10, quantity: 100000)
      @items = create_list(:item, 10, merchant: @merchant)
      @items2 = create_list(:item, 10, merchant: @merchant2)
  
      @customers = create_list(:customer, 2)
      @customer = create(:customer)
  
      @invs_0 = create_list(:invoice, 3, customer: @customers[0]) #
      @invs_1 = create_list(:invoice, 2, customer: @customers[1])
      @invs_2 = create_list(:invoice, 2, customer: @customer)
  
      @inv_item_1 = create(:invoice_item, invoice: @invs_0[0], item: @items[0]) #this will always belong to @merchants[0]
      @inv_item_2 = create(:invoice_item, invoice: @invs_0[1], item: @items[1]) #this will always belong to @merchants[0]
      @inv_item_3 = create(:invoice_item, invoice: @invs_0[0], item: @items[2]) #this will always belong to @merchants[0]      
      @inv_item_4 = create(:invoice_item, invoice: @invs_0[0], item: @items[3]) #this will always belong to @merchants[0]      
      @inv_item_5 = create(:invoice_item, invoice: @invs_1[1], item: @items2[6]) #this will always belong to @merchants[0]      
    end

    it 'can navigate to the show page from the index page' do
      visit merchant_invoices_path(@merchant)

      within "#invoice-#{@invs_0[0].id}" do
        click_link "#{@invs_0[0].id}"
        expect(current_path).to eq merchant_invoice_path(@merchant, @invs_0[0])
      end
    end

    it 'has the invoice information' do
      visit merchant_invoice_path(@merchant, @invs_0[0])

      within ".invoice" do
        expect(page).to have_content("#{@invs_0[0].id}")
        expect(page).to have_content("#{@invs_0[0].status}")
        expect(page).to have_content("#{@invs_0[0].created_at.strftime("%A, %B %d, %Y")}")
        expect(page).to have_content("#{@invs_0[0].customer.first_name} #{@invs_0[0].customer.last_name}")
      end

    end

    it 'shows the items that are associated with the invoice' do
      visit merchant_invoice_path(@merchant, @invs_0[0])

      within ".items" do
        within "#item-#{@items[0].id}" do
          expect(page).to have_content("#{@items[0].name}")
          expect(page).to have_content("#{@inv_item_1.quantity}")
          expect(page).to have_content("$#{((@items[0].unit_price.to_f) / 100).round(3)}")
          expect(page).to have_content("#{@inv_item_1.status}")
        end
      end

      within ".items" do
        expect(page).to_not have_content("#{@invs_2[0].id}")
        expect(page).to_not have_content("#{@invs_2[1].id}")
      end
    end
  end

  describe 'total_revenue' do
    before :each do
      @merchant = create(:merchant)
      @bulk_discount = create(:bulk_discount, merchant: @merchant, percentage: 10, quantity: 100000)

      @customer = create(:customer)
      
      @item = create(:item, merchant: @merchant, unit_price: 100)
      @item_2 = create(:item, merchant: @merchant, unit_price: 100)

      @invoice = create(:invoice, customer: @customer, status: 1)

      @invoice_items = create(:invoice_item, item: @item, invoice: @invoice, unit_price: @item.unit_price, quantity: 1)
      @invoice_items = create(:invoice_item, item: @item_2, invoice: @invoice, unit_price: @item_2.unit_price, quantity: 1)
    end

    it 'shows the total revenue earned from the invoice' do
      visit merchant_invoice_path(@merchant, @invoice)

      expect(page).to have_content("Total Revenue:")
      expect(page).to have_content("$2.00")
    end
  end

  describe 'merchant invoice revenue' do

    it 'shows the total revenue for only this merchant for this invoice' do
      merchants = create_list(:merchant, 2)
      invoice = create(:invoice)

      item_0a = create(:item, merchant: merchants[0], unit_price: 1000)
      item_0b = create(:item, merchant: merchants[0], unit_price: 2000)
      item_1 = create(:item, merchant: merchants[1], unit_price: 500)

      inv_item_0a = create(:invoice_item, quantity: 1, unit_price: item_0a.unit_price, invoice: invoice, merchant: merchants[0])
      inv_item_0b = create(:invoice_item, quantity: 3, unit_price: item_0b.unit_price, invoice: invoice, merchant: merchants[0])
      inv_item_1 = create(:invoice_item, quantity: 3, unit_price: item_1.unit_price, invoice: invoice, merchant: merchants[1])

      visit merchant_invoice_path(merchants[0], invoice)
      expect(invoice.total_revenue).to eq(8500)
      expect(page).to have_content("Total Merchant Revenue: $70.00")
    end

    it 'shows the total discounted revenue for only tthis merchant for this invoice' do
      merchants = create_list(:merchant, 2)
      invoice = create(:invoice)

      bulk_discount_a = create(:bulk_discount, percentage: 20, quantity: 10, merchant: merchants[0])
      bulk_discount_b = create(:bulk_discount, percentage: 30, quantity: 15, merchant: merchants[0])
      bulk_discount_c = create(:bulk_discount, percentage: 30, quantity: 17, merchant: merchants[1])

      item_a1 = create(:item, merchant: merchants[0], unit_price: 5000)
      item_a2 = create(:item, merchant: merchants[0], unit_price: 700)
      item_a3 = create(:item, merchant: merchants[0], unit_price: 1000)
      item_a4 = create(:item, merchant: merchants[0], unit_price: 1000)
      item_b = create(:item, merchant: merchants[1], unit_price: 1500)

      inv_item_a1 = create(:invoice_item, quantity: 12, unit_price: item_a1.unit_price, invoice: invoice, merchant: merchants[0])
      inv_item_a2 = create(:invoice_item, quantity: 15, unit_price: item_a2.unit_price, invoice: invoice, merchant: merchants[0])
      inv_item_a3 = create(:invoice_item, quantity: 9, unit_price: item_a3.unit_price, invoice: invoice, merchant: merchants[0])
      inv_item_a4 = create(:invoice_item, quantity: 10, unit_price: item_a4.unit_price, invoice: invoice, merchant: merchants[0])
      inv_item_b = create(:invoice_item, quantity: 15, unit_price: item_b.unit_price, invoice: invoice, merchant: merchants[1])
      visit merchant_invoice_path(merchants[0], invoice)
     
      expect(page).to have_content("Total Merchant Discounted Revenue: $723.50")
    end
  end

  describe 'discounted_revenue' do
    before :each do
      @merchant = create(:merchant)
      @bulk_discount = create(:bulk_discount, merchant: @merchant, percentage: 10, quantity: 2)
      @items = create_list(:item, 8, merchant: @merchant, unit_price: 500)
      @invoice = create(:invoice)
      @inv_item_eligible_0 = create(:invoice_item, item: @items[0], invoice: @invoice, quantity: 3, unit_price: @items[0].unit_price)
      @inv_item_eligible_1 = create(:invoice_item, item: @items[1], invoice: @invoice, quantity: 2, unit_price: @items[0].unit_price)
      @inv_items_ineligible = create_list(:invoice_item, 3, item: @items[7], invoice: @invoice, quantity: 1, unit_price: @items[1].unit_price)
      
      visit merchant_invoice_path(@merchant, @invoice)
    end

    it 'shows the discounted revenue earned from the invoice' do
      
      expect(page).to have_content("Discounted Revenue: $67.50")
    end

    it 'has a link to view a discount if invoice item is eligible for a discount' do
      save_and_open_page
      expect(page).to have_link("View Applied Discount", count: 2)

      #within block and click
    end
  end


  describe 'update item status' do

    before :each do
      @merchant = create(:merchant)
      @bulk_discount = create(:bulk_discount, merchant: @merchant, percentage: 10, quantity: 100000)

      @customer = create(:customer)
      
      @item = create(:item, merchant: @merchant, unit_price: 100)
      @item_2 = create(:item, merchant: @merchant, unit_price: 100)
      @item_3 = create(:item, merchant: @merchant, unit_price: 100)

      @invoice = create(:invoice, customer: @customer, status: 1)

      @invoice_items = create(:invoice_item, item: @item, invoice: @invoice, unit_price: @item.unit_price, status: 0) #pending
      @invoice_items = create(:invoice_item, item: @item_2, invoice: @invoice, unit_price: @item_2.unit_price, status: 1) #packaged
      @invoice_items = create(:invoice_item, item: @item_3, invoice: @invoice, unit_price: @item_3.unit_price, status: 2) #shipped
    end

    it 'can change the item status to Packaged' do
      visit merchant_invoice_path(@merchant, @invoice)

      within ".items" do
        within "#item-#{@item.id}" do
          expect(page).to have_content("Invoice Status: Pending")
            within "#status-update-#{@item.id}" do
              select 'Packaged', from: "status"
              click_button 'Submit'
              expect(current_path).to eq merchant_invoice_path(@merchant, @invoice)
            end
          
          expect(page).to have_content("Invoice Status: Packaged")
        end
      end
    end

    it 'can change the item status to Pending' do
      visit merchant_invoice_path(@merchant, @invoice)

      within ".items" do
        within "#item-#{@item_3.id}" do
          expect(page).to have_content("Invoice Status: Shipped")
            within "#status-update-#{@item_3.id}" do
              select 'Packaged', from: "status"
              click_button 'Submit'
              expect(current_path).to eq merchant_invoice_path(@merchant, @invoice)
            end
          expect(page).to_not have_content("Invoice Status: Pending")
          expect(page).to have_content("Invoice Status: Packaged")
        end
      end
    end

    it 'can change the item status to Shipped' do
      visit merchant_invoice_path(@merchant, @invoice)

      within ".items" do
        within "#item-#{@item_2.id}" do
          expect(page).to have_content("Invoice Status: Packaged")
            within "#status-update-#{@item_2.id}" do
              select 'Packaged', from: "status"
              click_button 'Submit'
              expect(current_path).to eq merchant_invoice_path(@merchant, @invoice)
            end
          expect(page).to_not have_content("Invoice Status: Pending")
          expect(page).to have_content("Invoice Status: Packaged")
        end
      end
    end

  end

end