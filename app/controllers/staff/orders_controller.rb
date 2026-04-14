module Staff
  class OrdersController < BaseController
    before_action :set_order, only: [ :show, :advance, :cancel ]

    def index
      scope = Order.includes(:user, :location, :order_items).order(:created_at)
      status_filter = params[:status].presence || "active"
      scope = case status_filter
              when "active"    then scope.where(status: %w[pending preparing ready])
              when "completed" then scope.where(status: "completed")
              when "cancelled" then scope.where(status: "cancelled")
              else scope
              end
      @orders = scope.limit(100)
      @status_filter = status_filter
    end

    def show; end

    def advance
      @order.advance_status!
      redirect_to staff_orders_path, notice: "Order #{@order.reference} → #{@order.status}"
    end

    def cancel
      @order.update(status: "cancelled")
      redirect_to staff_orders_path, notice: "Order cancelled."
    end

    private

    def set_order
      @order = Order.find(params[:id])
    end
  end
end
