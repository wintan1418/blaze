module Admin
  class OrdersController < BaseController
    before_action :set_order, only: [ :show, :update, :mark_dispatched, :mark_delivered ]

    def index
      scope = Order.includes(:user, :location, :order_items).order(created_at: :desc)
      scope = scope.where(status: params[:status]) if params[:status].present?
      @pagy, @orders = pagy(scope, limit: 25)
    end

    def show; end

    def mark_dispatched
      @order.mark_dispatched!
      redirect_to admin_order_path(@order), notice: "Order dispatched."
    end

    def mark_delivered
      @order.mark_delivered!
      redirect_to admin_order_path(@order), notice: "Order marked delivered."
    end

    def update
      if @order.update(order_params)
        redirect_to admin_orders_path, notice: "Order updated."
      else
        redirect_to admin_order_path(@order), alert: "Could not update."
      end
    end

    private

    def set_order
      @order = Order.find(params[:id])
    end

    def order_params
      params.require(:order).permit(:status, :payment_status, :notes)
    end
  end
end
