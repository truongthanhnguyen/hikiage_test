class CreateOrderReferenceDetails < ActiveRecord::Migration
  def change
    create_table :order_reference_details do |t|
      t.references :order
      t.string :amazon_order_reference_id
      t.string :status

      t.timestamps null: false
    end
  end
end
