class CreateRefundDetails < ActiveRecord::Migration
  def change
    create_table :refund_details do |t|
      t.string :amazon_capture_id
      t.string :refund_reference_id
      t.integer :refund_amount
      t.integer :fee_refunded
      t.string :status

      t.timestamps null: false
    end
  end
end
