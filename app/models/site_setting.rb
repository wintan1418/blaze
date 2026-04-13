class SiteSetting < ApplicationRecord
  has_one_attached :logo_image
  has_one_attached :og_image

  SECTION_KEYS = %i[
    menu_marquee
    vibe_gallery
    featured_dishes
    experiences
    cinema_strip
    testimonial
    locations
    cta_band
  ].freeze

  DEFAULT_SECTIONS = SECTION_KEYS.index_with { |_| true }.freeze

  validates :site_name, :tagline, :primary_color, :accent_color, :ink_color, presence: true
  validates :primary_color, :accent_color, :ember_color, :ink_color, :ash_color, :smoke_color,
            format: { with: /\A[0-9A-Fa-f]{6}\z/, message: "must be a 6-char hex without #" }

  # Singleton-style access — one row per installation.
  def self.current
    first_or_create!
  rescue ActiveRecord::RecordNotUnique
    first
  end

  def section_enabled?(key)
    sections_hash.fetch(key.to_s, true)
  end

  def sections_hash
    raw = sections.is_a?(Hash) ? sections : {}
    DEFAULT_SECTIONS.stringify_keys.merge(raw.stringify_keys)
  end

  def hero_headline_line2_html
    return hero_headline_line2.to_s unless hero_headline_accent.present?
    accent = Regexp.escape(hero_headline_accent)
    hero_headline_line2.to_s.sub(
      /#{accent}/i,
      %(<span class="fire-text italic">\\0</span>)
    ).html_safe
  end

  # Google Fonts query string, e.g. "Space+Grotesk:wght@400;500;600;700"
  def google_fonts_href
    families = [
      "#{display_font.tr(' ', '+')}:wght@400;500;600;700",
      "#{body_font.tr(' ', '+')}:wght@300;400;500;600"
    ].uniq
    "https://fonts.googleapis.com/css2?#{families.map { |f| "family=#{f}" }.join('&')}&display=swap"
  end

  # Delivery fee for this order's subtotal, respecting free-over threshold.
  def delivery_fee_for(subtotal_kobo)
    return 0 unless delivery_enabled
    return 0 if delivery_free_over_kobo.to_i > 0 && subtotal_kobo.to_i >= delivery_free_over_kobo.to_i
    delivery_fee_kobo.to_i
  end

  # Returns CSS custom property overrides for :root.
  def css_variables
    {
      "--color-blaze-red"   => "##{primary_color}",
      "--color-blaze-ember" => "##{ember_color}",
      "--color-blaze-amber" => "##{accent_color}",
      "--color-blaze-ink"   => "##{ink_color}",
      "--color-blaze-ash"   => "##{ash_color}",
      "--color-blaze-smoke" => "##{smoke_color}",
      "--font-display"      => %("#{display_font}", ui-sans-serif, system-ui, sans-serif),
      "--font-body"         => %("#{body_font}", ui-sans-serif, system-ui, sans-serif)
    }
  end
end
