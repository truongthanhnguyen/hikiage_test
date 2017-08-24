class SaveOrderReference
  MERCHANT_ID = 'MERCHANT_ID'
  ACCESS_KEY = 'ACCESS_KEY'
  SECRET_KEY = 'SECRET_KEY'

  def client
    @client ||= AmazonPay::Client.new(
      MERCHANT_ID,
      ACCESS_KEY,
      SECRET_KEY,
      sandbox: true,
      currency_code: :jpy,
      region: :jp
    )
  end


  def initialize order_reference_id, amount, access_key: nil,
    seller_note: "", seller_order_id: "test", store_name: "test"
    @amazon_order_reference_id = order_reference_id
    @amount = amount.to_i
    @access_key = access_key
    @seller_note = seller_note
    @seller_order_id = seller_order_id
    @store_name = store_name
  end

  def call
    binding.pry
    client.set_order_reference_details(
      @amazon_order_reference_id,
      @amount,
      seller_note: @seller_note,
      seller_order_id: @seller_order_id,
      store_name: @store_name
    )

    client.confirm_order_reference(@amazon_order_reference_id)
    binding.pry
    response = client.get_order_reference_details(
      @amazon_order_reference_id
    )
    binding.pry
  end
end
