require 'rails_helper'

RSpec.describe InvoiceItem, type: :model do
  describe 'validations' do
    it { should validate_presence_of :item_id }
    it { should validate_presence_of :invoice_id }
    it { should validate_presence_of :quantity }
    it { should validate_numericality_of(:quantity)}
    it { should validate_presence_of :unit_price }
    it { should validate_numericality_of(:unit_price) }
    it { should validate_presence_of :status }
    it { should define_enum_for(:status).with_values(["Pending", "Packaged", "Shipped"])}
  end

  describe 'relationships' do
    it { should belong_to :item}
    it { should belong_to :invoice}
    it { should have_one(:merchant).through(:item)}
    it { should have_many(:bulk_discounts).through(:merchant)}
  end

  it 'instantiates with factorybot' do
    customer = create(:customer)
    merchant = create(:merchant)
    item = merchant.items.create(attributes_for(:item))
    invoice = customer.invoices.create(attributes_for(:invoice))
    inv_item = create(:invoice_item, invoice_id: invoice.id, item_id: item.id)
  end

  it 'instantiates without parents' do
    inv_item = create(:invoice_item)
    #calling parents: inv_item.invoice.customer
    #calling parents: inv_item.item.merchant
  end

  describe "class methods" do
    describe "#unshipped_invoice_items" do
      it 'returns all invoice items with a status of pending or packaged' do
        inv_items_pending = create_list(:invoice_item, 5, status: 0)
        inv_items_packaged = create_list(:invoice_item, 5, status: 1)
        inv_items_shipped = create_list(:invoice_item, 5, status: 2)
        all_inv_items = InvoiceItem.all
        
        all_inv_items.unshipped_invoice_items.each do |ii|
          expect(ii.status).to_not eq("Shipped")
        end
        expect(InvoiceItem.unshipped_invoice_items.count).to eq(10)
      end
    end
  end

  describe 'instance methods' do
    # describe '#discount_amount' do
    #   it 'calculates the discount amount' do
    #     merchant = create(:merchant)
    #     bulk_discount = create(:bulk_discount, merchant: merchant, percentage: 10, quantity: 2)
    #     item = create(:item, merchant: merchant, unit_price: 500)
    #     invoice = create(:invoice)
    #     inv_item = create_list(:invoice_item, 3, item: item, invoice: invoice, quantity: 3, unit_price: item.unit_price)
        
    #     expect(inv_item[0].discount_amount).to eq(150)
    #   end
    # end

    describe '#self.invoice_items_eligible_for_discount' do
      it 'can tell which invoice items are eligible for a discount' do
        merchant = create(:merchant)
        bulk_discount = create(:bulk_discount, merchant: merchant, percentage: 10, quantity: 2)
        item = create(:item, merchant: merchant, unit_price: 500)
        invoice = create(:invoice)
        inv_items_eligible = create_list(:invoice_item, 3, item: item, invoice: invoice, quantity: 2, unit_price: item.unit_price)
        inv_items_ineligible = create_list(:invoice_item, 3, item: item, invoice: invoice, quantity: 1, unit_price: item.unit_price)

        expect(InvoiceItem.invoice_items_eligible_for_discount).to eq(inv_items_eligible)
      end

      it 'can tell which invoice items are not eligible for a discount' do
        merchant = create(:merchant)
        bulk_discount = create(:bulk_discount, merchant: merchant, percentage: 20, quantity: 10)
        items = create_list(:item, 2, merchant: merchant)
        invoice = create(:invoice)
        inv_item_a = create(:invoice_item, quantity: 5, item: items[0])
        inv_item_b = create(:invoice_item, quantity: 5, item: items[1])
       
        expect(InvoiceItem.invoice_items_eligible_for_discount).to eq([])
      end

      it 'can discount one item but not another' do
        merchant = create(:merchant)
        bulk_discount = create(:bulk_discount, merchant: merchant, percentage: 20, quantity: 10)
        items = create_list(:item, 2, merchant: merchant)
        invoice = create(:invoice)
        inv_item_a = create(:invoice_item, quantity: 10, item: items[0])
        inv_item_b = create(:invoice_item, quantity: 5, item: items[1])
      
        expect(InvoiceItem.invoice_items_eligible_for_discount).to eq([inv_item_a])
      end

      describe "#best_discount" do
        xit 'can tell what the best discount is' do
          merchant = create(:merchant)
          invoice = create(:invoice)
          
          bulk_discount_a = create(:bulk_discount, merchant: merchant, percentage: 20, quantity: 10)
          bulk_discount_b = create(:bulk_discount, merchant: merchant, percentage: 30, quantity: 15)
          
          item_a = create(:item, merchant: merchant)
          item_b = create(:item, merchant: merchant)
         
          inv_item_a = create(:invoice_item, quantity: 12, item: item_a, invoice: invoice)
          inv_item_b = create(:invoice_item, quantity: 15, item: item_b, invoice: invoice)

          expect(inv_item_a.best_discount).to eq(bulk_discount_a)
        end

        it 'can tell what the best discount is' do
          merchant = create(:merchant)
          invoice = create(:invoice)
          
          bulk_discount_a = create(:bulk_discount, merchant: merchant, percentage: 20, quantity: 10)
          bulk_discount_b = create(:bulk_discount, merchant: merchant, percentage: 30, quantity: 15)
          
          item_a = create(:item, merchant: merchant)
          item_b = create(:item, merchant: merchant)
         
          inv_item_a = create(:invoice_item, quantity: 12, item: item_a, invoice: invoice)
          inv_item_b = create(:invoice_item, quantity: 15, item: item_b, invoice: invoice)

          expect(inv_item_a.invoice_item_best_discount).to eq(bulk_discount_a.id)
          expect(inv_item_b.invoice_item_best_discount).to eq(bulk_discount_b.id)
        end
      end






      describe '#eligible_for_discount?' do ###needs a refactor
        xit 'can tell if an invoice item is eligible for a discount' do
          merchant = create(:merchant)
          bulk_discount = create(:bulk_discount, merchant: merchant, percentage: 10, quantity: 2)
          item = create(:item, merchant: merchant, unit_price: 500)
          invoice = create(:invoice)
          inv_items_eligible = create_list(:invoice_item, 3, item: item, invoice: invoice, quantity: 2, unit_price: item.unit_price)
          inv_items_ineligible = create_list(:invoice_item, 3, item: item, invoice: invoice, quantity: 1, unit_price: item.unit_price)
          
        
          expect(inv_items_eligible[0].eligible_for_discount?).to eq(true)
          expect(inv_items_ineligible[0].eligible_for_discount?).to eq(false)
        end
      end
    end
  end
end