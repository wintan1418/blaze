module Admin
  class MenuItemsController < BaseController
    before_action :set_item, only: [ :edit, :update, :destroy ]

    def index
      @items = MenuItem.includes(:menu_category).order(:menu_category_id, :name)
    end

    def new
      @item = MenuItem.new
    end

    def create
      @item = MenuItem.new(item_params)
      if @item.save
        redirect_to admin_menu_items_path, notice: "Menu item created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @item.update(item_params)
        redirect_to admin_menu_items_path, notice: "Menu item updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @item.destroy
      redirect_to admin_menu_items_path, notice: "Menu item deleted."
    end

    private

    def set_item
      @item = MenuItem.friendly.find(params[:id])
    end

    def item_params
      params.require(:menu_item).permit(
        :name, :description, :price_naira, :menu_category_id,
        :available, :featured, :preparation_time, :image
      )
    end
  end
end
