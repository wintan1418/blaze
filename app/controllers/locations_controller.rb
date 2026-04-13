class LocationsController < ApplicationController
  def index
    @locations = Location.active.order(:name)
  end

  def show
    @location = Location.friendly.find(params[:id])
    @upcoming_screenings = @location.screenings.upcoming.limit(4)
    @consoles_count = @location.gaming_consoles.active.count
  end
end
