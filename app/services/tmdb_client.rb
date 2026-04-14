require "net/http"
require "uri"
require "json"

# Thin TMDB (themoviedb.org) API wrapper.
#
# Get a free API key at https://www.themoviedb.org/settings/api (takes 60s).
# Add to env as TMDB_API_KEY=your_v3_api_key.
#
# Usage:
#   movie = TmdbClient.search_movie("Gangs of Lagos")
#   TmdbClient.poster_url(movie[:poster_path])  # => "https://image.tmdb.org/t/p/w780/..."
class TmdbClient
  API_BASE   = "https://api.themoviedb.org/3".freeze
  IMAGE_BASE = "https://image.tmdb.org/t/p".freeze

  class Error < StandardError; end

  class << self
    def configured?
      api_key.present?
    end

    def api_key
      ENV["TMDB_API_KEY"]
    end

    # Returns the best match for the given title, or nil.
    #   { id:, title:, release_date:, overview:, poster_path:, backdrop_path: }
    def search_movie(title, year: nil)
      raise Error, "TMDB not configured (set TMDB_API_KEY)" unless configured?

      params = {
        api_key: api_key,
        query:   title,
        include_adult: false,
        language: "en-US"
      }
      params[:year] = year if year

      data = get("/search/movie", params)
      first = (data["results"] || []).first
      return nil unless first

      {
        id:           first["id"],
        title:        first["title"],
        release_date: first["release_date"],
        overview:     first["overview"],
        poster_path:  first["poster_path"],
        backdrop_path: first["backdrop_path"]
      }
    end

    # Returns a poster URL at the given size (w92, w154, w185, w342, w500, w780, original).
    def poster_url(poster_path, size: "w780")
      return nil if poster_path.blank?
      "#{IMAGE_BASE}/#{size}#{poster_path}"
    end

    def backdrop_url(backdrop_path, size: "w1280")
      return nil if backdrop_path.blank?
      "#{IMAGE_BASE}/#{size}#{backdrop_path}"
    end

    private

    def get(path, params = {})
      uri = URI.join(API_BASE, path.sub(%r{\A/}, ""))
      uri.query = URI.encode_www_form(params)

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = 15
      http.open_timeout = 10

      res = http.request(Net::HTTP::Get.new(uri.request_uri))
      parsed = JSON.parse(res.body.to_s)

      unless res.is_a?(Net::HTTPSuccess)
        raise Error, "TMDB #{res.code}: #{parsed['status_message'] || res.body}"
      end

      parsed
    rescue JSON::ParserError
      raise Error, "TMDB returned invalid JSON"
    rescue Net::OpenTimeout, Net::ReadTimeout, SocketError => e
      raise Error, "TMDB unreachable: #{e.message}"
    end
  end
end
