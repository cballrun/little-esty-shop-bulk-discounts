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
  end
    
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
    describe '#total_invoice_revenue' do
      it 'calculates the total invoice revenue' do
        invoices = create_list(:invoice, 3)

        inv_items_0 = create_list(:invoice_item, 3, invoice: invoices[0], unit_price: 1000, quantity: 1)
        inv_items_1 = create_list(:invoice_item, 3, invoice: invoices[1], unit_price: 2000, quantity: 2)
        inv_items_2 = create_list(:invoice_item, 3, invoice: invoices[2], unit_price: 3000, quantity: 3)
        
        expect(invoices[0].total_invoice_revenue).to eq(3000)
        expect(invoices[1].total_invoice_revenue).to eq(12000)
        expect(invoices[2].total_invoice_revenue).to eq(27000)
      end
    end

    it 'calculates total invoice revenue in dollars' do
      invoices = create_list(:invoice, 3)

      inv_items_0 = create_list(:invoice_item, 3, invoice: invoices[0], unit_price: 1000, quantity: 1)
      inv_items_1 = create_list(:invoice_item, 3, invoice: invoices[1], unit_price: 2000, quantity: 2)
      inv_items_2 = create_list(:invoice_item, 3, invoice: invoices[2], unit_price: 3000, quantity: 3)
      
      expect(invoices[0].total_invoice_revenue_dollars).to eq(30.00)
      expect(invoices[1].total_invoice_revenue_dollars).to eq(120.00)
      expect(invoices[2].total_invoice_revenue_dollars).to eq(270.00)
    end
  end
end
