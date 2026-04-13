class GamingSlotsController < ApplicationController
  def index
    @locations = Location.active.includes(:gaming_consoles)
    @selected_location = if params[:location].present?
      Location.friendly.find(params[:location])
    else
      @locations.first
    end
    return unless @selected_location

    @selected_date = (params[:date].presence || Date.current.to_s).to_date

    @slots = GamingSlot
               .joins(gaming_console: :location)
               .where(locations: { id: @selected_location.id })
               .where(starts_at: @selected_date.beginning_of_day..@selected_date.end_of_day)
               .includes(:gaming_console, bookings: {})
               .order(:starts_at)

    @consoles = @selected_location.gaming_consoles.active.order(:number)
    @slot_grid = @slots.group_by(&:gaming_console_id)
  end

  def show
    @slot = GamingSlot.includes(:gaming_console).find(params[:id])
  end
end
