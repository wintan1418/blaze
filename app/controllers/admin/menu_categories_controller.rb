module Admin
  class MenuCategoriesController < BaseController
    before_action :set_category, only: [ :edit, :update, :destroy ]

    def index
      @categories = MenuCategory.ordered
    end

    def new
      @category = MenuCategory.new
    end

    def create
      @category = MenuCategory.new(category_params)
      if @category.save
        redirect_to admin_menu_categories_path, notice: "Category created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @category.update(category_params)
        redirect_to admin_menu_categories_path, notice: "Category updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @category.destroy
      redirect_to admin_menu_categories_path, notice: "Category deleted."
    end

    private

    def set_category
      @category = MenuCategory.friendly.find(params[:id])
    end

    def category_params
      params.require(:menu_category).permit(:name, :position, :accent_color)
    end
  end
end
