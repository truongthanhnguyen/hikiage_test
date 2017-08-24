class Amazon::SaveOrderReference
  include Amazon::Constant
  include Amazon::CommonMethods

  def initialize order, amazon_order_reference_attrs
    @order = order
    @order_reference_uid = amazon_order_reference_attrs.fetch :amazon_order_reference_id
    @payment_config = order.shop.payment_config
    @amazon_order_reference = AmazonOrderReference.new order: order,
      amazon_username: amazon_order_reference_attrs.fetch(:amazon_username),
      amazon_email: amazon_order_reference_attrs.fetch(:amazon_email),
      amazon_order_reference_uid: order_reference_uid
    @currency = order.currency
  end

  def call
    ActiveRecord::Base.transaction do
      set_order_reference_details
      confirm_order_reference
      order_reference_details = get_order_reference_details

      constraint_id = order_reference_details.get_element(
        ORDER_REFERENCE_CONSTRAINTS_XPATH, CONSTRAINT_ID_ELEMENT)
      constraint_description = order_reference_details.get_element(
        ORDER_REFERENCE_CONSTRAINTS_XPATH, CONSTRAINT_DESCRIPTION_ELEMENT)

      if constraint_id.present?
        error_message = "#{constraint_id}: #{constraint_description}"
        raise UkokkeiPayment::Error::AmazonError, error_message
      end
    
      @amazon_order_reference.save!
      result = Amazon::CreateAuthorizeOrderReference.new(order).call
      unless result.success?
        raise UkokkeiPayment::Error::AmazonError, result.errors.first
      end
    end

    ServiceResult.new success: true, data: amazon_order_reference

  rescue StandardError => e
    UkokkeiCore::Utility.log_exception e,
      info: "Called SaveOrderReference.call with #{order.inspect} and #{order_reference_uid}"
    ServiceResult.new success: false, data: amazon_order_reference, errors: [e]
  end

  private

  attr_reader :order, :order_reference_uid, :amazon_order_reference

  def set_order_reference_details
    response = client.set_order_reference_details(
      order_reference_uid,
      amount: order.total,
      currency_code: order.currency&.iso_code,
      seller_note: order.memos.first&.content,
      seller_order_id: order.uid,
      store_name: order.shop.name
    )
    check_response response
  end

  def confirm_order_reference
    response = client.confirm_order_reference order_reference_uid
    check_response response
  end

  def get_order_reference_details
    response = client.get_order_reference_details order_reference_uid
    check_response response

    response
  end
end
