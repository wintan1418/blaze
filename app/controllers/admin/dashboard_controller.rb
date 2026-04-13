module Admin
  class DashboardController < BaseController
    def index
      @stats = {
        menu_items: MenuItem.count,
        locations: Location.count,
        active_consoles: GamingConsole.active.count,
        upcoming_slots: GamingSlot.upcoming.count,
        upcoming_screenings: Screening.upcoming.count,
        bookings_today: Booking.where(created_at: Time.current.all_day).count,
        bookings_total: Booking.count,
        users_total: User.count
      }
      @recent_bookings = Booking.includes(:user, :bookable).order(created_at: :desc).limit(8)
      @upcoming_screenings = Screening.upcoming.includes(:screen).limit(5)
    end
  end
end
