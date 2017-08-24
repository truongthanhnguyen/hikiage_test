require "pry"
class Amazon::CreateAuthorizeOrderReference
  include Amazon::Constant
  include Amazon::CommonMethods

  attr_reader :order, :amazon_order_reference

  def initialize order
    @order = order
    @amazon_order_reference = order.amazon_order_references.last
    @payment_config = order.shop.payment_config
    @currency = order.currency
  end

  def call
    authorization_reference_id = order.uid
    response = client.authorize(
      amazon_order_reference.amazon_order_reference_uid,
      authorization_reference_id,
      amount: order.total,
      currency_code: order.currency&.iso_code,
      seller_authorization_note: order.memos.first&.content,
      transaction_timeout: 0,
      capture_now: false
    )
    check_response response
    authorization_status = response.get_element(AUTHORIZATION_STATUS_XPATH, STATUS_ELEMENT).downcase.to_sym
    if authorization_status.in? AmazonAuthorization::EXCEPT_STATUSES
      raise UkokkeiPayment::Error::AmazonError, "Authorization status is #{authorization_status}"
    end

    authorization_uid = response.get_element(
      AUTHORIZATION_DETAILS_XPATH, AUTHORIZATION_ID_ELEMENT).squish
    amazon_authorization = amazon_order_reference.amazon_authorization
    unless amazon_authorization.present?
      amazon_authorization = amazon_order_reference.build_amazon_authorization(
        amazon_order_reference: amazon_order_reference,
        amazon_authorization_uid: authorization_uid,
        status: authorization_status
      )
    end
    amazon_authorization.amazon_authorization_uid = nil
    amazon_authorization.status = authorization_status
    amazon_authorization.save!

    ServiceResult.new success: true, data: amazon_order_reference.amazon_authorization

  rescue StandardError => e
    UkokkeiCore::Utility.log_exception e,
      info: "Called CreateAuthorizeOrderReference.call with #{order.inspect} and #{amazon_order_reference}"
    result = ServiceResult.new success: false, errors: [e]
    result
  end
end
