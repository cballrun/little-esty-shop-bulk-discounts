require 'rails_helper'

RSpec.describe Invoice, type: :model do
  describe 'validations' do
    it { should validate_presence_of :status }
    it { should validate_presence_of :customer_id }
    it { should define_enum_for(:status).with_values(["In Progress", "Completed", "Cancelled"])}

  end

  describe 'relationships' do
    it { should belong_to :customer }
    it { should have_many :invoice_items }
    it { should have_many(:items).through(:invoice_items) }
    it { should have_many :transactions }
    it { should have_many(:merchants).through(:items)}
    it { should have_many(:bulk_discounts).through(:merchants)}
  end
    
  describe 'factorybot' do
    it 'instantiates with factorybot' do
      customer = create(:customer)
      invoice = customer.invoices.create(attributes_for(:invoice))
      x = create_list(:invoice, 10, customer: customer)
    end

    it 'instantiates without creating parents' do
      invoice = create(:invoice)
      #calling parents: invoice.customer 
    end

    it 'creates a list of invoices belonging to one customer' do
      customer = create(:customer)
      customer_invoices = create_list(:invoice, 10, customer: customer)
    end

    it 'creates a list of 10 customers' do
      customers = create_list(:customer, 10)
    end
  end


  describe 'instance methods' do
    describe 'find_invoice_item_quantity(invoice, item)' do
      it 'can find an instance of invoice_item_quantity' do
          @merchant = create(:merchant)
          @merchant2 = create(:merchant)
          
          @items = create_list(:item, 10, merchant: @merchant)
          @items2 = create_list(:item, 10, merchant: @merchant2)
      
          @customers = create_list(:customer, 2)
          @customer = create(:customer)
      
          @invs_0 = create_list(:invoice, 3, customer: @customers[0]) #
          @invs_1 = create_list(:invoice, 2, customer: @customers[1])
          @invs_2 = create_list(:invoice, 2, customer: @customer)
      
          @inv_item_1 = create(:invoice_item, invoice: @invs_0[0], item: @items[0], quantity: 1) #this will always belong to @merchants[0]
          @inv_item_2 = create(:invoice_item, invoice: @invs_0[1], item: @items[1], quantity: 1) #this will always belong to @merchants[0]
          @inv_item_3 = create(:invoice_item, invoice: @invs_0[2], item: @items[2], quantity: 1) #this will always belong to @merchants[0]      
    
          @inv_item_4 = create(:invoice_item, invoice: @invs_1[1], item: @items[1], quantity: 1) #this will always belong to @merchants[0]      
          @inv_item_5 = create(:invoice_item, invoice: @invs_2[1], item: @items2[6], quantity: 1) #this will always belong to @merchants[0]      

          expect(@invs_0[1].find_invoice_item_quantity(@invs_0[1], @items[1])).to eq 1
      end
    end

    describe 'find_invoice_item_status(invoice, item)' do
      it 'can find an instance of invoice_item_quantity' do
          @merchant = create(:merchant)
          @merchant2 = create(:merchant)
          
          @items = create_list(:item, 10, merchant: @merchant)
          @items2 = create_list(:item, 10, merchant: @merchant2)
      
          @customers = create_list(:customer, 2)
          @customer = create(:customer)
      
          @invs_0 = create_list(:invoice, 3, customer: @customers[0]) #
          @invs_1 = create_list(:invoice, 2, customer: @customers[1])
          @invs_2 = create_list(:invoice, 2, customer: @customer)
      
          @inv_item_1 = create(:invoice_item, invoice: @invs_0[0], item: @items[0], quantity: 1) #this will always belong to @merchants[0]
          @inv_item_2 = create(:invoice_item, invoice: @invs_0[1], item: @items[1], quantity: 1, status: 0) #this will always belong to @merchants[0]
          @inv_item_3 = create(:invoice_item, invoice: @invs_0[2], item: @items[2], quantity: 1) #this will always belong to @merchants[0]      
    
          @inv_item_4 = create(:invoice_item, invoice: @invs_1[1], item: @items[1], quantity: 1) #this will always belong to @merchants[0]      
          @inv_item_5 = create(:invoice_item, invoice: @invs_2[1], item: @items2[6], quantity: 1) #this will always belong to @merchants[0]      

          expect(@invs_0[1].find_invoice_item_status(@invs_0[1], @items[1])).to eq "Pending"
      end
    end

    describe '.revenue' do
      
      before :each do
        @merchant = create(:merchant)

        @customer = create(:customer)
        
        @item = create(:item, merchant: @merchant, unit_price: 100)
        @item_2 = create(:item, merchant: @merchant, unit_price: 100)

        @invoice = create(:invoice, customer: @customer, status: 1)

        @invoice_items = create(:invoice_item, item: @item, invoice: @invoice, unit_price: @item.unit_price, quantity: 1)
        @invoice_items = create(:invoice_item, item: @item_2, invoice: @invoice, unit_price: @item_2.unit_price, quantity: 1)
      end

      it 'can find the sum of each items total revenue for the invoice' do
        expect(@invoice.total_revenue).to eq 200
      end
    end
  end


  describe 'class methods' do
    describe '#incomplete_invoices_sorted' do
      it 'finds invoices that have invoice items that have not been shipped' do
        invoices = create_list(:invoice, 5)
        
        inv_items_0_shipped = create_list(:invoice_item, 5, invoice: invoices[0], status: 2)
       
        inv_items_1_shipped = create_list(:invoice_item, 5, invoice: invoices[1], status: 2)
        inv_items_1_pending= create_list(:invoice_item, 2, invoice: invoices[1], status: 0)
        inv_items_1_packaged = create_list(:invoice_item, 2, invoice: invoices[1], status: 1)

        inv_items_2_shipped = create_list(:invoice_item, 5, invoice: invoices[2], status: 2)

        inv_items_3_pending = create_list(:invoice_item, 5, invoice: invoices[3], status: 0)

        inv_items_4_packaged = create_list(:invoice_item, 5, invoice: invoices[4], status: 1)
        
        expect(Invoice.incomplete_invoices_sorted).to eq([invoices[1], invoices[3], invoices[4]])
      end

      it 'orders invoices with invoice items that have not been shipped by date' do
        oldest_inv = create(:invoice, created_at: 2.day.ago)
        middle_inv = create(:invoice, created_at: Date.today)
        newest_inv = create(:invoice, created_at: Date.tomorrow)
        
        oldest_inv_items = create_list(:invoice_item, 5, invoice: oldest_inv, status: 1)
        middle_inv_items = create_list(:invoice_item, 5, invoice: middle_inv, status: 0)
        newest_inv_items = create_list(:invoice_item, 5, invoice: newest_inv, status: 1)
        
        expect(Invoice.incomplete_invoices_sorted).to eq([oldest_inv, middle_inv, newest_inv])
      end
    end
  end


  describe 'instance methods' do
    describe '#total_invoice_revenue_for_merchant' do
      it 'calculates the total invoice revenue for one merchant' do
        merchants = create_list(:merchant, 2)
        invoice = create(:invoice)

        item_0 = create(:item, merchant: merchants[0], unit_price: 200)
        item_1 = create(:item, merchant: merchants[1], unit_price: 500)

        inv_item_0 = create(:invoice_item, quantity: 1, unit_price: item_0.unit_price, invoice: invoice, merchant: merchants[0])
        inv_item_1 = create(:invoice_item, quantity: 3, unit_price: item_1.unit_price, invoice: invoice, merchant: merchants[1])
       
        expect(invoice.total_invoice_revenue_for_merchant(merchants[0].id)).to eq(200)
        expect(invoice.total_invoice_revenue_for_merchant(merchants[1].id)).to eq(1500)
      end
    end

    describe '#total_best_discount_amount_for_merchant' do
      it 'calculates the total of the best discounts for one merchant' do
        merchant = create(:merchant, id: 1)
        invoice = create(:invoice)

        bulk_discount_a = create(:bulk_discount, percentage: 20, quantity: 10, merchant: merchant)
        bulk_discount_b = create(:bulk_discount, percentage: 30, quantity: 15, merchant: merchant)

        item_a = create(:item, merchant: merchant, unit_price: 1000)
        item_b = create(:item, merchant: merchant, unit_price: 500)

        inv_item_a = create(:invoice_item, quantity: 12, unit_price: item_a.unit_price, invoice: invoice, merchant: merchant)
        inv_item_b = create(:invoice_item, quantity:15, unit_price: item_b.unit_price, invoice: invoice, merchant: merchant)
        
        expect(invoice.total_best_discount_amount_for_merchant(merchant.id)).to eq(4650)
      end

      it 'calculates the total of the best discounts if there are multiple merchants on the invoice' do
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

    
        expect(invoice.total_best_discount_amount_for_merchant(merchants[0].id)).to eq(17150)
        expect(invoice.total_best_discount_amount_for_merchant(merchants[1].id)).to eq(0)
      end
    end

    describe '#total_discounted_revenue_for_merchant' do
      it 'calculates the total discounted revenue for a merchant' do
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


        expect(invoice.total_discounted_revenue_for_merchant(merchants[0].id)).to eq(72350)
      end
    end

    
    
  describe '#discounted_revenue' do
    it 'can tell what its discounted revenue is' do
      merchant = create(:merchant)
      bulk_discount = create(:bulk_discount, merchant: merchant, percentage: 10, quantity: 2)
      item = create(:item, merchant: merchant, unit_price: 500)
      invoice = create(:invoice)
      inv_items_eligible = create_list(:invoice_item, 3, item: item, invoice: invoice, quantity: 3, unit_price: item.unit_price)
      inv_items_ineligible = create_list(:invoice_item, 3, item: item, invoice: invoice, quantity: 1, unit_price: item.unit_price)
      
      expect(invoice.discounted_revenue).to eq(35550)
    end

    it 'can tell what its discounted revenue is with multiple merchants on the invoice' do
      merchants = create_list(:merchant, 2)
      invoice = create(:invoice)

      bulk_discount_a = create(:bulk_discount, percentage: 20, quantity: 10, merchant: merchants[0])
      bulk_discount_b = create(:bulk_discount, percentage: 30, quantity: 15, merchant: merchants[0])
      bulk_discount_c = create(:bulk_discount, percentage: 30, quantity: 17, merchant: merchants[1])

      item_a1 = create(:item, merchant: merchants[0], unit_price: 4000)
      item_a2 = create(:item, merchant: merchants[0], unit_price: 700)
      item_a3 = create(:item, merchant: merchants[0], unit_price: 1000)
      item_a4 = create(:item, merchant: merchants[0], unit_price: 1000)
      item_b = create(:item, merchant: merchants[1], unit_price: 1500)

      inv_item_a1 = create(:invoice_item, quantity: 12, unit_price: item_a1.unit_price, invoice: invoice, merchant: merchants[0])
      inv_item_a2 = create(:invoice_item, quantity: 15, unit_price: item_a2.unit_price, invoice: invoice, merchant: merchants[0])
      inv_item_a3 = create(:invoice_item, quantity: 9, unit_price: item_a3.unit_price, invoice: invoice, merchant: merchants[0])
      inv_item_a4 = create(:invoice_item, quantity: 10, unit_price: item_a4.unit_price, invoice: invoice, merchant: merchants[0])
      inv_item_b = create(:invoice_item, quantity: 15, unit_price: item_b.unit_price, invoice: invoice, merchant: merchants[1])

      expect(invoice.discounted_revenue).to eq(85250)
    end
  end

  

    describe ("#discount_amount") do

      it 'calculates the total invoice discount' do
        merchant = create(:merchant)
        bulk_discount = create(:bulk_discount, merchant: merchant, percentage: 10, quantity: 2)
        item = create(:item, merchant: merchant, unit_price: 500)
        invoice = create(:invoice)
        inv_items_eligible = create_list(:invoice_item, 3, item: item, invoice: invoice, quantity: 3, unit_price: item.unit_price)
        inv_items_ineligible = create_list(:invoice_item, 3, item: item, invoice: invoice, quantity: 1, unit_price: item.unit_price)
        
        
        expect(invoice.discount_amount).to eq(450)
      end
    end

    it 'can tell what its discounted revenue is' do
      merchant = create(:merchant)
      bulk_discount = create(:bulk_discount, merchant: merchant, percentage: 10, quantity: 2)
      item = create(:item, merchant: merchant, unit_price: 500)
      invoice = create(:invoice)
      inv_items_eligible = create_list(:invoice_item, 3, item: item, invoice: invoice, quantity: 3, unit_price: item.unit_price)
      inv_items_ineligible = create_list(:invoice_item, 3, item: item, invoice: invoice, quantity: 1, unit_price: item.unit_price)
      
      expect(invoice.discounted_revenue).to eq(35550)
    end

    it 'can pick the best discount out of multiple discounts for multiple merchants' do
      merchants = create_list(:merchant, 2)
      invoice = create(:invoice)

      bulk_discount_a = create(:bulk_discount, percentage: 20, quantity: 10, merchant: merchants[0])
      bulk_discount_b = create(:bulk_discount, percentage: 30, quantity: 15, merchant: merchants[0])
      bulk_discount_c = create(:bulk_discount, percentage: 30, quantity: 17, merchant: merchants[1])

      item_a1 = create(:item, merchant: merchants[0], unit_price: 4000)
      item_a2 = create(:item, merchant: merchants[0], unit_price: 700)
      item_a3 = create(:item, merchant: merchants[0], unit_price: 1000)
      item_a4 = create(:item, merchant: merchants[0], unit_price: 1000)
      item_b = create(:item, merchant: merchants[1], unit_price: 1500)

      inv_item_a1 = create(:invoice_item, quantity: 12, unit_price: item_a1.unit_price, invoice: invoice, merchant: merchants[0])
      inv_item_a2 = create(:invoice_item, quantity: 15, unit_price: item_a2.unit_price, invoice: invoice, merchant: merchants[0])
      inv_item_a3 = create(:invoice_item, quantity: 9, unit_price: item_a3.unit_price, invoice: invoice, merchant: merchants[0])
      inv_item_a4 = create(:invoice_item, quantity: 10, unit_price: item_a4.unit_price, invoice: invoice, merchant: merchants[0])
      inv_item_b = create(:invoice_item, quantity: 15, unit_price: item_b.unit_price, invoice: invoice, merchant: merchants[1])

      expect(invoice.discount_amount).to eq(14750)
    end
  end
end
