class OrderReferenceDetail < ActiveRecord::Base
  has_many :authorization_details
  belongs_to :order
end
