module Admin
  class SpecialsController < BaseController
    before_action :set_special, only: [ :edit, :update, :destroy ]

    def index
      @specials = Special.includes(:menu_item, :screening, :location).ordered
    end

    def new
      @special = Special.new(
        active: true,
        kind: "food",
        slots_total: 20,
        slots_claimed: 0,
        starts_at: Time.current.beginning_of_day + 10.hours,
        ends_at:   Time.current.beginning_of_day + 22.hours
      )
    end

    def create
      @special = Special.new(special_params)
      if @special.save
        redirect_to admin_specials_path, notice: "Special '#{@special.name}' created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @special.update(special_params)
        redirect_to admin_specials_path, notice: "Special updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @special.destroy
      redirect_to admin_specials_path, notice: "Special removed."
    end

    private

    def set_special
      @special = Special.friendly.find(params[:id])
    end

    def special_params
      params.require(:special).permit(
        :name, :description, :kind, :price_kobo, :original_price_kobo,
        :slots_total, :slots_claimed, :starts_at, :ends_at, :active,
        :image_url, :image, :location_id, :menu_item_id, :screening_id
      )
    end
  end
end
