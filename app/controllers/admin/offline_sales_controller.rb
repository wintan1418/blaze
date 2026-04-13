module Admin
  class OfflineSalesController < BaseController
    before_action :set_sale, only: [ :edit, :update, :destroy ]

    def index
      scope = OfflineSale.includes(:menu_item, :location, :recorded_by).recent

      @from = (params[:from].presence || 7.days.ago.to_date.to_s).to_date
      @to   = (params[:to].presence || Date.current.to_s).to_date
      scope = scope.for_range(@from.beginning_of_day..@to.end_of_day)

      scope = scope.where(location_id: params[:location_id]) if params[:location_id].present?
      scope = scope.where(payment_method: params[:payment_method]) if params[:payment_method].present?

      @totals = {
        count: scope.count,
        revenue: scope.sum(:total_kobo),
        by_method: scope.reorder(nil).group(:payment_method).sum(:total_kobo)
      }

      @pagy, @sales = pagy(scope, limit: 25)
    end

    def new
      @sale = OfflineSale.new(
        sold_at: Time.current,
        quantity: 1,
        payment_method: "cash",
        recorded_by: current_user
      )
    end

    def create
      @sale = OfflineSale.new(sale_params)
      @sale.recorded_by = current_user
      if @sale.save
        redirect_to admin_offline_sales_path, notice: "Sale recorded."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @sale.update(sale_params)
        redirect_to admin_offline_sales_path, notice: "Sale updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @sale.destroy
      redirect_to admin_offline_sales_path, notice: "Sale removed."
    end

    private

    def set_sale
      @sale = OfflineSale.find(params[:id])
    end

    def sale_params
      params.require(:offline_sale).permit(
        :menu_item_id, :location_id, :quantity, :unit_price_kobo,
        :description, :payment_method, :notes, :sold_at
      )
    end
  end
end
