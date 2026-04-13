class ScreeningsController < ApplicationController
  def index
    @pagy, @screenings = pagy(
      Screening.upcoming.available.includes(screen: :location),
      limit: 12
    )
  end

  def show
    @screening = Screening.friendly.find(params[:id])
  end
end
