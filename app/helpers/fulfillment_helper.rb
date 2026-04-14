module FulfillmentHelper
  # Returns the appropriate "how to claim this" instruction for the customer
  # based on the order's fulfillment type, or a sensible default for bookings.
  def fulfillment_instruction(record)
    case record
    when Order
      case record.fulfillment
      when "delivery"
        "Our driver will call you before arrival. Keep your phone on."
      when "dine_in"
        "Show this reference at your table."
      else
        "Show this reference at the counter."
      end
    when Booking
      if record.bookable.is_a?(GamingSlot)
        "Show this reference at the gaming counter on arrival."
      elsif record.bookable.is_a?(Screening)
        "Show this reference at the cinema entrance."
      else
        "Show this reference at the counter."
      end
    else
      "Show this reference at the counter."
    end
  end
end
