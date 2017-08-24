class Amazon::CancelOrderReference
  include Amazon::Constant
  include Amazon::CommonMethods

  def initialize order
    @order = order
    @payment_config = order.shop.payment_config
    @amazon_order_reference = order.amazon_order_references&.last
    @currency = order.currency
  end

  def call
    ActiveRecord::Base.transaction do
      if amazon_order_reference.nil?
        raise UkokkeiPayment::Error::AmazonError,
          "#{order.uid} don't has amazon_order_reference"
      end
      amazon_authorization = amazon_order_reference.amazon_authorization
      amazon_capture = amazon_authorization.amazon_capture
      if amazon_order_reference.cancelable?
        cancel_amazon_order_reference_request
        amazon_authorization.closed!
        amazon_capture.closed! if amazon_capture
        amazon_order_reference.closed!
      else
        raise UkokkeiPayment::Error::AmazonError,
          "#{order.uid} can't cancel amazon_order_reference"
      end
    end

    ServiceResult.new success: true, data: amazon_order_reference

  rescue StandardError => e
    UkokkeiCore::Utility.log_exception e,
      info: "Called CancelOrderReference.call with #{order.inspect} and
        #{amazon_order_reference&.amazon_order_reference_uid}"
    ServiceResult.new success: false, data: amazon_order_reference, errors: [e]
  end

  private
  attr_reader :order, :amazon_order_reference

  def cancel_amazon_order_reference_request
    response = client.cancel_order_reference(
      amazon_order_reference.amazon_order_reference_uid
    )
    check_response response
  end
end
