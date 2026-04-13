require "net/http"
require "uri"
require "json"

# Termii SMS wrapper — https://developer.termii.com/
# Falls back to logging when TERMII_LIVE != "true" so dev doesn't burn credits.
class TermiiClient
  API_BASE = "https://api.ng.termii.com".freeze

  class Error < StandardError; end

  class << self
    def configured?
      api_key.present? && sender_id.present?
    end

    def live?
      ENV["TERMII_LIVE"].to_s.downcase == "true"
    end

    def api_key
      ENV["TERMII_API_KEY"]
    end

    def sender_id
      ENV["TERMII_SENDER_ID"]
    end

    # Send a plain SMS.
    def send_sms(phone:, message:, channel: "generic")
      to = normalize_phone(phone)
      return { skipped: true, reason: "invalid phone" } if to.blank?
      return { skipped: true, reason: "not configured" } unless configured?

      unless live?
        Rails.logger.info("[Termii stub] → #{to}: #{message.truncate(120)}")
        return { stubbed: true, to: to, message: message }
      end

      body = {
        to: to,
        from: sender_id,
        sms: message,
        type: "plain",
        channel: channel,
        api_key: api_key
      }

      post("/api/sms/send", body)
    end

    # Convenience: send the Blaze Cafe order confirmation SMS.
    def send_order_confirmation(order)
      phone = order.user.phone
      return { skipped: true, reason: "no phone on user" } if phone.blank?

      items_summary = order.order_items.map { |oi| "#{oi.quantity}x #{oi.name_snapshot}" }.join(", ")
      location_name = order.location&.name || "Blaze Cafe"
      amount_naira = order.total_kobo / 100

      message = "BLAZE CAFE: Order #{order.reference} received (₦#{amount_naira}). #{items_summary}. #{order.fulfillment.humanize} @ #{location_name}. We'll text you when it's ready!"
      send_sms(phone: phone, message: message)
    end

    # Convenience: send the Blaze Cafe booking confirmation SMS.
    def send_booking_confirmation(booking)
      phone = booking.user.phone
      return { skipped: true, reason: "no phone on user" } if phone.blank?

      bookable = booking.bookable
      when_text =
        if bookable.respond_to?(:starts_at)
          bookable.starts_at.strftime("%a %b %d · %I:%M%p")
        else
          ""
        end

      subject =
        if bookable.is_a?(GamingSlot)
          "#{bookable.gaming_console.label} @ #{bookable.gaming_console.location.name}"
        elsif bookable.is_a?(Screening)
          "#{bookable.title} @ #{bookable.screen.location.name}"
        else
          "booking"
        end

      message = "BLAZE CAFE: Booking #{booking.reference} confirmed. #{subject}. #{when_text}. Show this SMS at the counter. Thank you!"
      send_sms(phone: phone, message: message)
    end

    private

    # Accept "+234812..." or "0812..." and normalize to "234812..." (no +, digits only).
    def normalize_phone(raw)
      return nil if raw.blank?
      digits = raw.to_s.gsub(/\D/, "")
      if digits.start_with?("234") && digits.length >= 13
        digits
      elsif digits.start_with?("0") && digits.length == 11
        "234#{digits[1..]}"
      elsif digits.length == 10
        "234#{digits}"
      else
        digits
      end
    end

    def post(path, body)
      uri = URI.join(API_BASE, path)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = 15
      http.open_timeout = 10

      req = Net::HTTP::Post.new(uri.request_uri)
      req["Content-Type"] = "application/json"
      req["Accept"] = "application/json"
      req.body = body.to_json

      res = http.request(req)
      parsed = (JSON.parse(res.body.to_s) rescue { "raw" => res.body })
      unless res.is_a?(Net::HTTPSuccess)
        Rails.logger.warn("[Termii] #{res.code}: #{parsed.inspect}")
      end
      parsed
    rescue StandardError => e
      Rails.logger.warn("[Termii] request failed: #{e.class}: #{e.message}")
      { error: e.message }
    end
  end
end
