module Admin
  class ScreeningsController < BaseController
    before_action :set_screening, only: [ :edit, :update, :destroy ]

    def index
      @screenings = Screening.includes(:screen).order(starts_at: :desc)
    end

    def new
      @screening = Screening.new
    end

    def create
      @screening = Screening.new(screening_params)
      if @screening.save
        redirect_to admin_screenings_path, notice: "Screening created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @screening.update(screening_params)
        redirect_to admin_screenings_path, notice: "Screening updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @screening.destroy
      redirect_to admin_screenings_path, notice: "Screening deleted."
    end

    private

    def set_screening
      @screening = Screening.friendly.find(params[:id])
    end

    def screening_params
      params.require(:screening).permit(:title, :synopsis, :starts_at, :ends_at, :screen_id, :price_kobo, :available, :poster)
    end
  end
end
