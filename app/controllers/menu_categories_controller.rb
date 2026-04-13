class MenuCategoriesController < ApplicationController
  def index
    redirect_to menu_items_path
  end

  def show
    @category = MenuCategory.friendly.find(params[:id])
    redirect_to menu_items_path(category: @category.slug), status: :see_other
  end
end
