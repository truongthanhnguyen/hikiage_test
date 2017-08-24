module Amazon::CommonMethods
  include Amazon::Constant

  def check_response response
    if response.code != SUCCESS_CODE
      error_message = response.get_element ERROR_RESPONSE_XPATH, ERROR_RESPONSE_ELEMENT
      raise UkokkeiPayment::Error::AmazonError, error_message
    end
  end

  private

  attr_reader :payment_config, :currency

  def client
    @client ||= AmazonPay::Client.new(
      payment_config.amazon_merchant_id,
      payment_config.amazon_access_key,
      payment_config.amazon_secret_key,
      sandbox: payment_config.is_use_amazon_sandbox,
      region: :jp,
      currency_code: currency.iso_code
    )
  end
end
