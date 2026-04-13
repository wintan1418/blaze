module ImageryHelper
  UNSPLASH_BASE = "https://images.unsplash.com/photo-".freeze

  # Verified Unsplash photo IDs, curated by vibe.
  HERO_DISHES = %w[
    1604329760661-e71dc83f8f26
    1574484284002-952d92456975
    1529006557810-274b9b2fc783
    1528605248644-14dd04022da1
    1511512578047-dfb367046420
    1552566626-52f8b828add9
    1511882150382-421056c89033
    1621996346565-e3dbc646d9a9
    1533777857889-4be7c70b33f7
  ].freeze

  # Mixed hero carousel: dishes, gaming, cinema — rotated so the reel shows
  # the full Blaze Cafe experience, not just food.
  HERO_SLIDES = [
    { photo_id: "1604329760661-e71dc83f8f26", kind: "Now serving", title: "Signature Jollof Rice",  meta: "₦2,500 · smoke · scotch bonnet" },
    { photo_id: "1550745165-9bc0b252726f",    kind: "Now live",    title: "PS5 Sessions",            meta: "₦1,500 · 30 minutes · book ahead" },
    { photo_id: "1528605248644-14dd04022da1", kind: "On the grill", title: "Peppered Goat Meat",     meta: "₦3,500 · slow-cooked · fiery" },
    { photo_id: "1489599849927-2ee91cede3ba", kind: "Tonight",     title: "Private Cinema",          meta: "₦3,500 · 24 seats · curated" },
    { photo_id: "1574484284002-952d92456975", kind: "From the bar", title: "Blaze Smoothie",         meta: "₦1,500 · mango · pineapple · ginger" },
    { photo_id: "1612287230202-1ff1d85d1bdf", kind: "Controller ready", title: "PS4 / PS5 Lounge",   meta: "18 consoles · 3 locations" },
    { photo_id: "1511512578047-dfb367046420", kind: "Chef's pick",  title: "Seafood Pasta",          meta: "₦3,800 · prawns · calamari" },
    { photo_id: "1486572788966-cfd3df1f5b42", kind: "This weekend", title: "The Black Book",         meta: "₦3,500 · main screen · 7pm" }
  ].freeze

  VIBE_GALLERY = %w[
    1542751371-adc38448a05e
    1585829365295-ab7cd400c167
    1472851294608-062f824d29cc
    1513475382585-d06e58bcb0e0
    1559305616-3f99cd43e353
    1600891964092-4316c288032e
    1609501676725-7186f017a4b7
    1504754524776-8f4f37790ca0
    1484723091739-30a097e8f929
    1493770348161-369560ae357d
    1555992336-fb0d29498b13
    1607013251379-e6eecfffe234
    1543339308-43e59d6b73a6
    1536098561742-ca998e48cbcc
    1598188306155-25e400eb5078
    1551538827-9c037cb4f32a
    1598515214211-89d3c73ae83b
  ].freeze

  EXPERIENCE_IMAGES = {
    food:    "1604329760661-e71dc83f8f26",
    drinks:  "1513475382585-d06e58bcb0e0",
    gaming:  "1542751371-adc38448a05e",
    cinema:  "1598188306155-25e400eb5078"
  }.freeze

  def unsplash_url(photo_id, w: 1600, h: 1200, fit: "crop", q: 80)
    "#{UNSPLASH_BASE}#{photo_id}?w=#{w}&h=#{h}&fit=#{fit}&q=#{q}&auto=format"
  end

  def hero_slides
    HERO_DISHES.map { |id| unsplash_url(id, w: 1800, h: 1200) }
  end

  # Returns an array of hashes: { url:, kind:, title:, meta: }
  def hero_reel
    HERO_SLIDES.map do |slide|
      {
        url:   unsplash_url(slide[:photo_id], w: 1800, h: 1400),
        kind:  slide[:kind],
        title: slide[:title],
        meta:  slide[:meta]
      }
    end
  end

  def vibe_gallery_urls(count = 8)
    VIBE_GALLERY.sample(count).map { |id| unsplash_url(id, w: 900, h: 1200) }
  end

  def experience_image(key, w: 1200, h: 900)
    unsplash_url(EXPERIENCE_IMAGES.fetch(key), w: w, h: h)
  end
end
