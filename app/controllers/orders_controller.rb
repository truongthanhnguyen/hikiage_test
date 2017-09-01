class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :edit, :update, :destroy]
  require "pay_with_amazon"

  # GET /orders
  # GET /orders.json
  def index
    @orders = Order.all
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
  end

  # GET /orders/new
  def new
    @order = Order.new
  end

  # GET /orders/1/edit
  def edit
  end

  # POST /orders
  # POST /orders.json
  def create
    merchant_id = "A3QCQLYZKBHFRS"
    access_key = "AKIAJ7QFPDNE5WCULPAQ"
    secret_key = "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"

    client = PayWithAmazon::Client.new(
      merchant_id,
      access_key,
      secret_key,
      sandbox: true,
      currency_code: :jpy,
      region: :jp
    )

    @order = Order.new order_params

    order_reference = OrderReferenceDetail.create amazon_order_reference_id: params[:order][:order_reference_id],
      order: @order, status: "Open"
    # lay gia tri order reference id
    # order_reference_id = params[:order][:order_reference_id] 
    # amount = params[:order][:total]

    # # tao client
    # @client ||= PayWithAmazon::Client.new(
    #   MERCHANT_ID,
    #   ACCESS_KEY,
    #   SECRET_KEY,
    #   sandbox: true,
    #   currency_code: :jpy,
    #   region: :jp
    # )

    # client.set_order_reference_details(
    #   order_reference_id,
    #   amount
    # )

    # # hay cho toi vao server lay du lieu di ! 
    # client.confirm_order_reference(order_reference_id)


    # # co dang la xml (cam on vi da cho toi keo du lieu ve)
    # response = client.get_order_reference_details(
    #   @amazon_order_reference_id
    # )

    SaveOrderReference.new(params[:order][:order_reference_id], params[:order][:total]).call
    respond_to do |format|
      format.html { redirect_to @order, notice: "Order was successfully created." }
      format.js 
    end

    address_consent_token = params[:order][:access_token]
    amazon_order_reference_id = OrderReferenceDetail.last.amazon_order_reference_id

    client.get_order_reference_details(
      amazon_order_reference_id,
      address_consent_token: address_consent_token
    )
  end

  def authorize
    merchant_id = "A3QCQLYZKBHFRS"
    access_key = "AKIAJ7QFPDNE5WCULPAQ"
    secret_key = "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"

    client = PayWithAmazon::Client.new(
      merchant_id,
      access_key,
      secret_key,
      sandbox: true,
      currency_code: :jpy,
      region: :jp
    )
    # binding.pry
    amazon_order_reference_id = OrderReferenceDetail.last.amazon_order_reference_id
    authorization_reference_id = "9_1_13_29"
    amount = 1

    response = client.authorize(
      amazon_order_reference_id,
      authorization_reference_id,
      amount,
      seller_authorization_note: 'Lorem ipsum dolor',
      transaction_timeout: 0, 
      mws_auth_token: 'amzn.mws.4ea38b7b-f563-7709-4bae-87aeaEXAMPLE'
    )
    
    amazon_authorization_id = response.get_element('AuthorizeResponse/AuthorizeResult/AuthorizationDetails','AmazonAuthorizationId')
    AuthorizationDetail.create amazon_authorization_id: amazon_authorization_id, amazon_order_reference_id: amazon_order_reference_id,
      authorization_reference_id: authorization_reference_id
    

    # client.close_order_reference(
    #   amazon_order_reference_id,
    #   mws_auth_token: 'amzn.mws.4ea38b7b-f563-7709-4bae-87aeaEXAMPLE'
    # )

    redirect_to orders_url
  end

  def capture
    merchant_id = "A3QCQLYZKBHFRS"
    access_key = "AKIAJ7QFPDNE5WCULPAQ"
    secret_key = "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"

    client = PayWithAmazon::Client.new(
      merchant_id,
      access_key,
      secret_key,
      sandbox: true,
      currency_code: :jpy,
      region: :jp
    )
    # binding.pry
    amazon_authorization_id = AuthorizationDetail.last.amazon_authorization_id
    capture_reference_id = "9_1_13_30"
    amount = 1

    response = client.capture(
      amazon_authorization_id,
      capture_reference_id,
      amount,
      seller_capture_note: 'Lorem ipsum dolor',
      mws_auth_token: 'amzn.mws.4ea38b7b-f563-7709-4bae-87aeaEXAMPLE'
    )

    amazon_capture_id = response.get_element('CaptureResponse/CaptureResult/CaptureDetails','AmazonCaptureId')
    CaptureDetail.create amazon_authorization_id: amazon_authorization_id, amazon_capture_id: amazon_capture_id,
      capture_reference_id: capture_reference_id

    redirect_to orders_url
  end

  def refund
    merchant_id = "A3QCQLYZKBHFRS"
    access_key = "AKIAJ7QFPDNE5WCULPAQ"
    secret_key = "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"

    client = PayWithAmazon::Client.new(
      merchant_id,
      access_key,
      secret_key,
      sandbox: true,
      currency_code: :jpy,
      region: :jp
    )
    # binding.pry
    amazon_capture_id = CaptureDetail.last.amazon_capture_id
    refund_reference_id = '9_1_13_31'
    amount = 1

    client.refund(
      amazon_capture_id,
      refund_reference_id,
      amount,
      seller_refund_note: 'Lorem ipsum dolor',
      mws_auth_token: 'amzn.mws.4ea38b7b-f563-7709-4bae-87aeaEXAMPLE'
    )

    redirect_to orders_url
  end

  def ipn_process
    # binding.pry
  end

  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  def update
    respond_to do |format|
      if @order.update(order_params)
        format.html { redirect_to @order, notice: "Order was successfully updated." }
        format.json { render :show, status: :ok, location: @order }
      else
        format.html { render :edit }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orders/1
  # DELETE /orders/1.json
  def destroy
    @order.destroy
    respond_to do |format|
      format.html { redirect_to orders_url, notice: "Order was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.require(:order).permit(:total)
    end
end
