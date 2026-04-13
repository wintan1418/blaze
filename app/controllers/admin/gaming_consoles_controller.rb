module Admin
  class GamingConsolesController < BaseController
    before_action :set_console, only: [ :edit, :update, :destroy ]

    def index
      @consoles = GamingConsole.includes(:location).order("locations.name", :number).references(:location)
    end

    def new
      @console = GamingConsole.new
    end

    def create
      @console = GamingConsole.new(console_params)
      if @console.save
        redirect_to admin_gaming_consoles_path, notice: "Console added."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @console.update(console_params)
        redirect_to admin_gaming_consoles_path, notice: "Console updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @console.destroy
      redirect_to admin_gaming_consoles_path, notice: "Console deleted."
    end

    private

    def set_console
      @console = GamingConsole.find(params[:id])
    end

    def console_params
      params.require(:gaming_console).permit(:number, :console_type, :location_id, :active)
    end
  end
end
