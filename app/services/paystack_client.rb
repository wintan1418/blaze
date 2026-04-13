require "net/http"
require "uri"
require "json"
require "openssl"

# Thin Paystack API wrapper using Net::HTTP (no gem dependency).
# Docs: https://paystack.com/docs/api/
class PaystackClient
  API_BASE = "https://api.paystack.co".freeze

  class Error < StandardError; end

  class << self
    def configured?
      secret_key.present?
    end

    def secret_key
      ENV["PAYSTACK_SECRET_KEY"]
    end

    def public_key
      ENV["PAYSTACK_PUBLIC_KEY"]
    end

    # Initialize a transaction. Returns a hash with :authorization_url, :access_code, :reference.
    # https://paystack.com/docs/api/transaction/#initialize
    def initialize_transaction(email:, amount_kobo:, reference:, callback_url:, metadata: {})
      raise Error, "Paystack not configured" unless configured?

      body = {
        email: email,
        amount: amount_kobo,
        reference: reference,
        callback_url: callback_url,
        currency: "NGN",
        metadata: metadata
      }

      response = post("/transaction/initialize", body)
      data = response.fetch("data", {})
      {
        authorization_url: data["authorization_url"],
        access_code: data["access_code"],
        reference: data["reference"]
      }
    end

    # Verify a transaction by reference.
    # Returns a hash: { success:, amount_kobo:, channel:, paid_at:, reference:, raw: }
    # https://paystack.com/docs/api/transaction/#verify
    def verify_transaction(reference)
      raise Error, "Paystack not configured" unless configured?

      response = get("/transaction/verify/#{reference}")
      data = response.fetch("data", {})
      {
        success: data["status"] == "success",
        status: data["status"],
        amount_kobo: data["amount"].to_i,
        channel: data["channel"],
        paid_at: (Time.zone.parse(data["paid_at"]) rescue nil),
        provider_reference: data["reference"],
        raw: data
      }
    end

    # Verify that a webhook request really came from Paystack.
    # https://paystack.com/docs/payments/webhooks/
    def valid_webhook_signature?(raw_body, signature_header)
      return false if signature_header.blank? || secret_key.blank?
      expected = OpenSSL::HMAC.hexdigest("sha512", secret_key, raw_body)
      ActiveSupport::SecurityUtils.secure_compare(expected, signature_header)
    end

    private

    def post(path, body)
      request(Net::HTTP::Post, path) { |req| req.body = body.to_json }
    end

    def get(path)
      request(Net::HTTP::Get, path)
    end

    def request(klass, path)
      uri = URI.join(API_BASE, path)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = 15
      http.open_timeout = 10

      req = klass.new(uri.request_uri)
      req["Authorization"] = "Bearer #{secret_key}"
      req["Content-Type"]  = "application/json"
      req["Accept"]        = "application/json"
      yield req if block_given?

      res = http.request(req)
      parsed = JSON.parse(res.body.to_s)
      unless res.is_a?(Net::HTTPSuccess)
        raise Error, "Paystack #{res.code}: #{parsed['message'] || res.body}"
      end
      parsed
    rescue JSON::ParserError
      raise Error, "Paystack returned invalid JSON"
    rescue Net::OpenTimeout, Net::ReadTimeout => e
      raise Error, "Paystack timeout: #{e.message}"
    end
  end
end
