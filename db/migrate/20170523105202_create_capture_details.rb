class CreateCaptureDetails < ActiveRecord::Migration
  def change
    create_table :capture_details do |t|
      t.string :amazon_authorization_id
      t.string :capture_reference_id
      t.string :amazon_capture_id
      t.integer :capture_amount
      t.integer :refunded_amount
      t.integer :capture_fee
      t.string :status

      t.timestamps null: false
    end
  end
end
