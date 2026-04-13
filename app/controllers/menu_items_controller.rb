class MenuItemsController < ApplicationController
  def index
    scope = MenuItem.available.includes(:menu_category, image_attachment: :blob)
    if params[:category].present?
      @active_category = MenuCategory.friendly.find(params[:category])
      scope = scope.where(menu_category: @active_category)
    end
    scope = scope.where("name ILIKE ?", "%#{params[:q]}%") if params[:q].present?
    @pagy, @items = pagy(scope.order(:name), limit: 24)
    @categories = MenuCategory.ordered
  end

  def show
    @item = MenuItem.friendly.find(params[:id])
    @related = @item.menu_category.menu_items.available.where.not(id: @item.id).limit(3)
  end
end
