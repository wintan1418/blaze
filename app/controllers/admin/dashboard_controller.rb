module Admin
  class DashboardController < BaseController
    def index
      @stats = {
        menu_items: MenuItem.count,
        locations: Location.count,
        active_consoles: GamingConsole.active.count,
        upcoming_slots: GamingSlot.upcoming.count,
        upcoming_screenings: Screening.upcoming.count,
        users_total: User.count,
        bookings_today: Booking.where(created_at: Time.current.all_day).count,
        orders_today: Order.where(created_at: Time.current.all_day).count
      }

      @range = 30.days.ago.beginning_of_day..Time.current.end_of_day
      @stats.merge!(revenue_stats(@range))

      # Daily revenue timeline across all sources
      @revenue_timeline = revenue_timeline(@range)
      @has_revenue = @revenue_timeline.any? { |s| s[:data].values.any? { |v| v.to_i > 0 } }

      # Revenue by source (pie)
      @revenue_by_source = {
        "Food orders"    => Order.paid.where(paid_at: @range).sum(:total_kobo),
        "Gaming"         => Booking.paid.joins("JOIN gaming_slots ON bookings.bookable_type = 'GamingSlot' AND bookings.bookable_id = gaming_slots.id").where(paid_at: @range).sum(:total_price_kobo),
        "Cinema"         => Booking.paid.joins("JOIN screenings ON bookings.bookable_type = 'Screening' AND bookings.bookable_id = screenings.id").where(paid_at: @range).sum(:total_price_kobo),
        "Offline sales"  => OfflineSale.where(sold_at: @range).sum(:total_kobo)
      }.transform_values { |v| v.to_i / 100 } # display as naira

      # Top menu items (online order items + offline sales, combined units)
      online_units = OrderItem.joins(:order)
                              .where(orders: { payment_status: "paid", paid_at: @range })
                              .group(:menu_item_id).sum(:quantity)
      offline_units = OfflineSale.where(sold_at: @range, menu_item_id: MenuItem.select(:id))
                                 .group(:menu_item_id).sum(:quantity)
      combined = Hash.new(0)
      online_units.each { |id, q| combined[id] += q }
      offline_units.each { |id, q| combined[id] += q }
      top_ids = combined.sort_by { |_, q| -q }.first(8).to_h
      names = MenuItem.where(id: top_ids.keys).pluck(:id, :name).to_h
      @top_items = top_ids.transform_keys { |id| names[id] || "Item ##{id}" }

      # Revenue by location (orders + offline sales + bookings via slots/screenings)
      @revenue_by_location = location_revenue(@range)

      @recent_bookings = Booking.includes(:user, :bookable).order(created_at: :desc).limit(6)
      @recent_orders   = Order.includes(:user, :order_items).order(created_at: :desc).limit(6)
    end

    private

    def revenue_stats(range)
      online_orders = Order.paid.where(paid_at: range).sum(:total_kobo)
      offline       = OfflineSale.where(sold_at: range).sum(:total_kobo)
      bookings      = Booking.paid.where(paid_at: range).sum(:total_price_kobo)
      {
        revenue_orders:   online_orders.to_i,
        revenue_offline:  offline.to_i,
        revenue_bookings: bookings.to_i,
        revenue_total:    online_orders.to_i + offline.to_i + bookings.to_i
      }
    end

    # Merge three time series (orders, bookings, offline sales) into a
    # Chartkick-friendly [{ name:, data: }] structure keyed by date.
    # Uses Postgres date_trunc directly so we don't depend on the Groupdate gem.
    def revenue_timeline(range)
      days = (range.begin.to_date..range.end.to_date).to_a
      empty_days = days.index_with { 0 }.stringify_keys

      orders   = date_bucket_sum(Order.paid.where(paid_at: range), :paid_at,  :total_kobo)
      bookings = date_bucket_sum(Booking.paid.where(paid_at: range), :paid_at, :total_price_kobo)
      offline  = date_bucket_sum(OfflineSale.where(sold_at: range), :sold_at, :total_kobo)

      to_naira = ->(h) { empty_days.merge(h).transform_values { |kobo| (kobo.to_i / 100) } }

      [
        { name: "Food orders",   data: to_naira.call(orders) },
        { name: "Bookings",      data: to_naira.call(bookings) },
        { name: "Offline sales", data: to_naira.call(offline) }
      ]
    end

    def date_bucket_sum(relation, date_col, sum_col)
      relation
        .reorder(nil)
        .group(Arel.sql("date_trunc('day', #{relation.connection.quote_column_name(date_col)})"))
        .sum(sum_col)
        .transform_keys { |ts| ts.is_a?(String) ? Date.parse(ts).to_s : ts.to_date.to_s }
    end

    def location_revenue(range)
      order_rev = Order.paid.where(paid_at: range).group(:location_id).sum(:total_kobo)
      offline_rev = OfflineSale.where(sold_at: range).group(:location_id).sum(:total_kobo)
      # Bookings via gaming: location is gaming_console.location
      gaming_rev = Booking.paid.where(paid_at: range, bookable_type: "GamingSlot")
                          .joins("JOIN gaming_slots ON bookings.bookable_id = gaming_slots.id")
                          .joins("JOIN gaming_consoles ON gaming_slots.gaming_console_id = gaming_consoles.id")
                          .group("gaming_consoles.location_id").sum(:total_price_kobo)
      # Cinema via screen
      cinema_rev = Booking.paid.where(paid_at: range, bookable_type: "Screening")
                          .joins("JOIN screenings ON bookings.bookable_id = screenings.id")
                          .joins("JOIN screens ON screenings.screen_id = screens.id")
                          .group("screens.location_id").sum(:total_price_kobo)

      combined = Hash.new(0)
      [ order_rev, offline_rev, gaming_rev, cinema_rev ].each do |h|
        h.each { |loc_id, sum| combined[loc_id] += sum.to_i if loc_id }
      end
      names = Location.where(id: combined.keys).pluck(:id, :name).to_h
      combined.transform_keys { |id| names[id] || "Unknown" }
              .transform_values { |v| v / 100 }
    end
  end
end
