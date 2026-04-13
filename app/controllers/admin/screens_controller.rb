module Admin
  class ScreensController < BaseController
    before_action :set_screen, only: [ :edit, :update, :destroy ]

    def index
      @screens = Screen.includes(:location).order("locations.name, screens.name").references(:location)
    end

    def new
      @screen = Screen.new
    end

    def create
      @screen = Screen.new(screen_params)
      if @screen.save
        redirect_to admin_screens_path, notice: "Screen created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @screen.update(screen_params)
        redirect_to admin_screens_path, notice: "Screen updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @screen.destroy
      redirect_to admin_screens_path, notice: "Screen deleted."
    end

    private

    def set_screen
      @screen = Screen.find(params[:id])
    end

    def screen_params
      params.require(:screen).permit(:name, :capacity, :location_id)
    end
  end
end
