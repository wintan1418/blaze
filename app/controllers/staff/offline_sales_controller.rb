module Staff
  class OfflineSalesController < BaseController
    def new
      @sale = OfflineSale.new(
        sold_at: Time.current,
        quantity: 1,
        payment_method: "cash",
        location: default_location
      )
      @menu_items = MenuItem.available.includes(:menu_category).order(:menu_category_id, :name)
    end

    def create
      @sale = OfflineSale.new(sale_params)
      @sale.recorded_by = current_user
      @sale.sold_at ||= Time.current

      if @sale.save
        redirect_to new_staff_offline_sale_path, notice: "Logged #{@sale.quantity}× #{@sale.label} · #{@sale.total_kobo / 100} ₦"
      else
        @menu_items = MenuItem.available.includes(:menu_category).order(:menu_category_id, :name)
        render :new, status: :unprocessable_entity
      end
    end

    private

    def default_location
      Location.active.first
    end

    def sale_params
      params.require(:offline_sale).permit(
        :menu_item_id, :location_id, :quantity, :unit_price_kobo,
        :description, :payment_method, :notes
      )
    end
  end
end
