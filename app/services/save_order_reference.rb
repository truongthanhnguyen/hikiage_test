class SaveOrderReference
  MERCHANT_ID = 'A3QCQLYZKBHFRS'
  ACCESS_KEY = 'AKIAJ7QFPDNE5WCULPAQ'
  SECRET_KEY = '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'

  def client
    @client ||= PayWithAmazon::Client.new(
      MERCHANT_ID,
      ACCESS_KEY,
      SECRET_KEY,
      sandbox: true,
      currency_code: :jpy,
      region: :jp
    )
  end

  def initialize order_reference_id, amount,
    seller_note: "", seller_order_id: "test", store_name: "test"
    @amazon_order_reference_id = order_reference_id
    @amount = amount.to_i
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
    binding.pry
    client.confirm_order_reference(@amazon_order_reference_id)
    binding.pry
    response = client.get_order_reference_details(
      @amazon_order_reference_id
    )
    binding.pry
  end
end
