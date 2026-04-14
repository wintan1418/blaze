# Central notification dispatcher.
#
# Fire an event and it fans out to SMS (Termii) and email (ActionMailer)
# based on the event's template. All channels are best-effort — a failure
# in one channel is logged but never raised back to the caller.
#
# Usage:
#   NotificationCenter.notify(:order_paid, order: order)
#   NotificationCenter.notify(:booking_confirmed, booking: booking)
class NotificationCenter
  EVENTS = %i[
    order_received
    order_paid
    order_ready
    order_out_for_delivery
    order_delivered
    order_cancelled
    booking_confirmed
    booking_cancelled
    booking_reminder
  ].freeze

  class << self
    def notify(event, **context)
      raise ArgumentError, "unknown event #{event}" unless EVENTS.include?(event)
      record  = context[:order] || context[:booking]
      user    = record&.user
      return unless user

      send_sms(event, record, user)
      send_email(event, record, user)
    rescue StandardError => e
      Rails.logger.error("[NotificationCenter] #{event} failed: #{e.class}: #{e.message}")
    end

    private

    def send_sms(event, record, user)
      message = sms_message(event, record)
      return if message.blank?
      TermiiClient.send_sms(phone: user.phone, message: message)
    rescue StandardError => e
      Rails.logger.warn("[NotificationCenter] SMS(#{event}) failed: #{e.message}")
    end

    def send_email(event, record, user)
      return if user.email.blank?
      case event
      when :order_received, :order_paid, :order_ready, :order_out_for_delivery, :order_delivered
        OrderMailer.with(order: record, event: event).status_update.deliver_later
      when :booking_confirmed
        BookingMailer.confirmation(record).deliver_later
      end
    rescue StandardError => e
      Rails.logger.warn("[NotificationCenter] Mail(#{event}) failed: #{e.message}")
    end

    def sms_message(event, record)
      case event
      when :order_received
        order = record
        items = order.order_items.map { |oi| "#{oi.quantity}x #{oi.name_snapshot}" }.join(", ")
        "BLAZE CAFE: Order #{order.reference} received. Items: #{items}. Total ₦#{naira(order.total_kobo)}. We'll text you when it's ready."
      when :order_paid
        "BLAZE CAFE: Payment confirmed for order #{record.reference} (₦#{naira(record.total_kobo)}). We're #{record.delivery? ? 'preparing your delivery' : 'preparing your order'}."
      when :order_ready
        if record.delivery?
          "BLAZE CAFE: Order #{record.reference} is leaving the kitchen — your driver is on the way."
        else
          "BLAZE CAFE: Your order #{record.reference} is ready! Come through to the counter. Show code: #{record.reference}"
        end
      when :order_out_for_delivery
        "BLAZE CAFE: Order #{record.reference} is out for delivery. Keep your phone on — the driver will call. Ref: #{record.reference}"
      when :order_delivered
        "BLAZE CAFE: Order #{record.reference} delivered. Enjoy the fire 🔥 We'd love a review!"
      when :order_cancelled
        "BLAZE CAFE: Order #{record.reference} has been cancelled. If this is unexpected, reach us on the contact page."
      when :booking_confirmed
        booking = record
        subject =
          if booking.bookable.is_a?(GamingSlot)
            "#{booking.bookable.gaming_console.label} @ #{booking.bookable.gaming_console.location.name}"
          elsif booking.bookable.is_a?(Screening)
            "#{booking.bookable.title} @ #{booking.bookable.screen.location.name}"
          end
        when_text = booking.bookable.starts_at.strftime("%a %b %d · %I:%M%p")
        "BLAZE CAFE: Booking #{booking.reference} confirmed. #{subject}. #{when_text}. Show the ref at the counter."
      when :booking_cancelled
        "BLAZE CAFE: Booking #{record.reference} cancelled. We hope to see you next time."
      when :booking_reminder
        when_text = record.bookable.starts_at.strftime("%I:%M%p")
        "BLAZE CAFE: Reminder — your booking #{record.reference} is at #{when_text} today. See you soon!"
      end
    end

    def naira(kobo)
      ((kobo.to_i / 100).to_s).reverse.scan(/\d{1,3}/).join(",").reverse
    end
  end
end
