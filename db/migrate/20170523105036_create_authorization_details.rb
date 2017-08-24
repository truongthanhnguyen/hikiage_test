class CreateAuthorizationDetails < ActiveRecord::Migration
  def change
    create_table :authorization_details do |t|
      t.string :amazon_authorization_id
      t.string :authorization_reference_id
      t.string :amazon_order_reference_id
      t.string :status

      t.timestamps null: false
    end
  end
end
