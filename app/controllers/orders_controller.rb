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
    @order = Order.new(order_params)
    @order.save
    order_referece = OrderReferenceDetail.create amazon_order_reference_id: params[:order][:order_reference_id],
      order: @order, status: "Open"
    SaveOrderReference.new(params[:order][:order_reference_id], params[:order][:total]).call

    format.html { redirect_to @order, notice: "Order was successfully created." }

    merchant_id = "A3QCQLYZKBHFRS"
    access_key = "AordersFPDNE5WCULPAQ"
    secret_key = "D+nDDFrrM1a19+T7arXuUBENbZOqw2a2saXniyFk"

    client = PayWithAmazon::Client.new(
      merchant_id,
      access_key,
      secret_key,
      sandbox: true,
      currency_code: :usd,
      region: :na
      )

    amazon_order_reference_id = "AMAZON_ORDER_REFERENCE_ID"
    address_consent_token = "ADDRESS_CONSENT_TOKEN"
    amount = 106

    client.get_order_reference_details(
      amazon_order_reference_id,
      amount,
      seller_note: "Lorem ipsum dolor",
      seller_order_id: "5678-23",
      store_name: "CourtAndCherry.com",
      address_consent_token: address_consent_token,
      mws_auth_token: "amzn.mws.4ea38b7b-f563-7709-4bae-87aeaEXAMPLE"
      ) 
    
    client.confirm_order_reference(
      amazon_order_reference_id,
      mws_auth_token: "amzn.mws.4ea38b7b-f563-7709-4bae-87aeaEXAMPLE"
      )
  end

  def authorize
    merchant_id = "A3QCQLYZKBHFRS"
    access_key = "AordersFPDNE5WCULPAQ"
    secret_key = "D+nDDFrrM1a19+T7arXuUBENbZOqw2a2saXniyFk"

    client = PayWithAmazon::Client.new(
      merchant_id,
      access_key,
      secret_key,
      sandbox: true,
      currency_code: :usd,
      region: :na
    )

    amazon_order_reference_id = 'AMAZON_ORDER_REFERENCE_ID'
    authorization_reference_id = 'test_authorize_1'
    amount = 94.50

    client.authorize(
      amazon_order_reference_id,
      authorization_reference_id,
      amount,
      seller_authorization_note: 'Lorem ipsum dolor',
      transaction_timeout: 60, 
      mws_auth_token: 'amzn.mws.4ea38b7b-f563-7709-4bae-87aeaEXAMPLE'
    )
    Authorize Synchronous API Call

    # Authorize - Synchronous 

    client.authorize(
      amazon_order_reference_id,
      authorization_reference_id,
      amount,
      seller_authorization_note: 'Lorem ipsum dolor',
      transaction_timeout: 0, 
      mws_auth_token: 'amzn.mws.4ea38b7b-f563-7709-4bae-87aeaEXAMPLE'
    )
  end

  def capture

  end

  def refund

  end

  def ipn_process
    binding.pry
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
