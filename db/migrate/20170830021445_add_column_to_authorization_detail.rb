class AddColumnToAuthorizationDetail < ActiveRecord::Migration
  def change
    add_column :authorization_details, :order_reference_detail_id, :integer
  end
end
