class Order < ActiveRecord::Base
  has_many :order_reference_details
  attr_accessor :access_token, :order_reference_id
end
