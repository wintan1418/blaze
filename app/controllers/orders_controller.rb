class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :load_cart, only: [ :new, :create ]

  def index
    @pagy, @orders = pagy(current_user.orders.recent.includes(:order_items), limit: 15)
  end

  def show
    @order = current_user.orders.find(params[:id])
  end

  def new
    if @cart.empty?
      redirect_to cart_path, alert: "Your cart is empty." and return
    end
    @order = current_user.orders.build(
      fulfillment: "pickup",
      location: Location.active.first,
      delivery_phone: current_user.phone,
      notes: ""
    )
    @cart_lines = @cart.items
  end

  def create
    if @cart.empty?
      redirect_to cart_path, alert: "Your cart is empty." and return
    end

    @order = current_user.orders.build(order_params)
    @cart.items.each do |line|
      @order.order_items.build(menu_item: line.menu_item, quantity: line.quantity)
    end

    if @order.delivery?
      subtotal = @cart.total_kobo
      @order.delivery_fee_kobo = site_setting.delivery_fee_for(subtotal)
    else
      @order.delivery_fee_kobo = 0
    end

    unless @order.save
      @cart_lines = @cart.items
      render :new, status: :unprocessable_entity and return
    end

    if PaystackClient.configured?
      begin
        payment = create_payment_for(@order)
        @cart.clear!
        redirect_to payment.authorization_url, allow_other_host: true
      rescue PaystackClient::Error => e
        flash[:alert] = "Payment could not be started: #{e.message}"
        redirect_to order_path(@order)
      end
    else
      @cart.clear!
      redirect_to order_path(@order), notice: "Order placed. Pay at the counter on pickup."
    end
  end

  private

  def load_cart
    @cart = Cart.new(session)
  end

  def order_params
    params.require(:order).permit(
      :location_id, :fulfillment, :notes,
      :delivery_address, :delivery_city, :delivery_phone
    )
  end

  def create_payment_for(order)
    payment = order.payments.create!(
      user: current_user,
      amount_kobo: order.total_kobo,
      status: "pending"
    )
    result = PaystackClient.initialize_transaction(
      email: current_user.email,
      amount_kobo: order.total_kobo,
      reference: payment.reference,
      callback_url: payments_callback_url,
      metadata: {
        order_ref: order.reference,
        payable_type: "Order",
        user_id: current_user.id
      }
    )
    payment.update!(authorization_url: result[:authorization_url])
    payment
  end
end
