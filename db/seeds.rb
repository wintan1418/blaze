# Idempotent seeds — safe to run multiple times.
# Usage: bin/rails db:seed
#
# Downloads real imagery from Unsplash + Foodish API + Picsum.
# Every attachment is wrapped in a rescue block so a broken URL never
# breaks the seed run — the record just gets no image (or falls back).

require "open-uri"

puts "🔥 Seeding Blaze Cafe..."

# ------------------------------------------------------------ Site settings
setting = SiteSetting.current
setting.sections = SiteSetting::DEFAULT_SECTIONS.stringify_keys if setting.sections.blank?
setting.instagram_url ||= "https://instagram.com/blazecafe.ng"
setting.tiktok_url    ||= "https://tiktok.com/@blazecafe.ng"
setting.x_url         ||= "https://x.com/blazecafe"
setting.save!
puts "  ✓ Site settings: #{setting.site_name}"

# ------------------------------------------------------------ Hero slides
hero_slides_data = [
  { position: 1, image_url: "https://images.unsplash.com/photo-1604329760661-e71dc83f8f26?w=1800&h=1400&fit=crop&q=80", kind: "Now serving",      title: "Signature Jollof Rice", meta: "₦2,500 · smoke · scotch bonnet" },
  { position: 2, image_url: "https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=1800&h=1400&fit=crop&q=80",    kind: "Now live",         title: "PS5 Sessions",           meta: "₦1,500 · 30 minutes · book ahead" },
  { position: 3, image_url: "https://images.unsplash.com/photo-1528605248644-14dd04022da1?w=1800&h=1400&fit=crop&q=80", kind: "On the grill",     title: "Peppered Goat Meat",     meta: "₦3,500 · slow-cooked · fiery" },
  { position: 4, image_url: "https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=1800&h=1400&fit=crop&q=80", kind: "Tonight",          title: "Private Cinema",         meta: "₦3,500 · 24 seats · curated" },
  { position: 5, image_url: "https://images.unsplash.com/photo-1574484284002-952d92456975?w=1800&h=1400&fit=crop&q=80", kind: "From the bar",     title: "Blaze Smoothie",         meta: "₦1,500 · mango · pineapple · ginger" },
  { position: 6, image_url: "https://images.unsplash.com/photo-1612287230202-1ff1d85d1bdf?w=1800&h=1400&fit=crop&q=80", kind: "Controller ready", title: "PS4 / PS5 Lounge",       meta: "18 consoles · 3 locations" },
  { position: 7, image_url: "https://images.unsplash.com/photo-1511512578047-dfb367046420?w=1800&h=1400&fit=crop&q=80", kind: "Chef's pick",      title: "Seafood Pasta",          meta: "₦3,800 · prawns · calamari" },
  { position: 8, image_url: "https://images.unsplash.com/photo-1486572788966-cfd3df1f5b42?w=1800&h=1400&fit=crop&q=80", kind: "This weekend",     title: "The Black Book",         meta: "₦3,500 · main screen · 7pm" }
]
hero_slides_data.each do |data|
  HeroSlide.find_or_create_by!(title: data[:title]) { |s| s.assign_attributes(data.merge(active: true)) }
end
puts "  ✓ Hero slides: #{HeroSlide.count}"

# ------------------------------------------------------------ image helpers
IMAGE_TIMEOUT = 15

def fetch_image(urls, filename_base)
  Array(urls).each do |url|
    begin
      io = URI.parse(url).open(read_timeout: IMAGE_TIMEOUT, "User-Agent" => "BlazeCafeSeed/1.0")
      ext = File.extname(URI.parse(url).path).presence || ".jpg"
      return [ io, "#{filename_base}#{ext}" ]
    rescue StandardError => e
      warn "   ⚠️  #{url} → #{e.class}: #{e.message}"
      next
    end
  end
  nil
end

def attach_image(record, field, urls, filename_base)
  return :already if record.send(field).attached?
  result = fetch_image(urls, filename_base)
  return :failed unless result
  io, filename = result
  record.send(field).attach(io: io, filename: filename, content_type: "image/jpeg")
  :attached
rescue StandardError => e
  warn "   ⚠️  attach failed: #{e.class}: #{e.message}"
  :failed
end

# ------------------------------------------------------------ Users
admin = User.find_or_initialize_by(email: "admin@blazecafe.ng")
admin.assign_attributes(
  password: "blazeadmin123",
  password_confirmation: "blazeadmin123",
  full_name: "Juwon (Admin)",
  phone: "+2348000000001",
  role: :admin
)
admin.save!
puts "  ✓ Admin user: #{admin.email}"

customer = User.find_or_initialize_by(email: "guest@blazecafe.ng")
customer.assign_attributes(
  password: "blazeguest123",
  password_confirmation: "blazeguest123",
  full_name: "Blaze Guest",
  phone: "+2348000000002",
  role: :customer
)
customer.save!
puts "  ✓ Demo customer: #{customer.email}"

extra_customers = [
  { email: "ada@example.ng",      name: "Ada Nwosu",         phone: "+2348011110001" },
  { email: "kunle@example.ng",    name: "Kunle Adebayo",     phone: "+2348011110002" },
  { email: "zainab@example.ng",   name: "Zainab Musa",       phone: "+2348011110003" },
  { email: "tope@example.ng",     name: "Tope Ogunleye",     phone: "+2348011110004" },
  { email: "ifeoma@example.ng",   name: "Ifeoma Eze",        phone: "+2348011110005" },
  { email: "chidera@example.ng",  name: "Chidera Okafor",    phone: "+2348011110006" },
  { email: "abdul@example.ng",    name: "Abdul Bello",       phone: "+2348011110007" },
  { email: "damola@example.ng",   name: "Damola Adeleke",    phone: "+2348011110008" },
  { email: "funke@example.ng",    name: "Funke Balogun",     phone: "+2348011110009" },
  { email: "yusuf@example.ng",    name: "Yusuf Aliyu",       phone: "+2348011110010" },
  { email: "blessing@example.ng", name: "Blessing Okonkwo",  phone: "+2348011110011" },
  { email: "seun@example.ng",     name: "Seun Akinwale",     phone: "+2348011110012" }
]
extra_customers.each do |data|
  u = User.find_or_initialize_by(email: data[:email])
  u.assign_attributes(
    password: "blazefan123",
    password_confirmation: "blazefan123",
    full_name: data[:name],
    phone: data[:phone],
    role: :customer
  )
  u.save!
end
puts "  ✓ Customer accounts: #{User.customer.count}"

# ------------------------------------------------------------ Locations
location_seeds = [
  {
    slug: "blaze-cafe-main-campus",
    name: "Blaze Cafe — Main Campus",
    address: "Adekunle Ajasin University, Akungba-Akoko",
    city: "Akungba-Akoko",
    phone: "+234 812 000 1000",
    hero_urls: [
      "https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=1600&h=1000&fit=crop&q=80",
      "https://picsum.photos/seed/blaze-main/1600/1000"
    ]
  },
  {
    slug: "blaze-cafe-akure",
    name: "Blaze Cafe — Akure Central",
    address: "Oba Adesida Rd, Opposite Shoprite, Akure",
    city: "Akure",
    phone: "+234 812 000 2000",
    hero_urls: [
      "https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=1600&h=1000&fit=crop&q=80",
      "https://picsum.photos/seed/blaze-akure/1600/1000"
    ]
  },
  {
    slug: "blaze-cafe-ondo-town",
    name: "Blaze Cafe — Ondo Town",
    address: "Yaba Street, Ondo City",
    city: "Ondo City",
    phone: "+234 812 000 3000",
    hero_urls: [
      "https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=1600&h=1000&fit=crop&q=80",
      "https://picsum.photos/seed/blaze-ondo/1600/1000"
    ]
  }
]

locations = location_seeds.map do |data|
  loc = Location.find_or_create_by!(slug: data[:slug]) do |l|
    l.name = data[:name]
    l.address = data[:address]
    l.city = data[:city]
    l.phone = data[:phone]
    l.active = true
  end
  result = attach_image(loc, :hero_image, data[:hero_urls], "hero-#{loc.slug}")
  print "  📸 hero for #{loc.name}: #{result}\n"
  loc
end
main, akure, ondo_town = locations
puts "  ✓ Locations: #{Location.count}"

# ------------------------------------------------------------ Menu categories
categories = {
  food:     MenuCategory.find_or_create_by!(slug: "food")     { |c| c.name = "Food";     c.position = 1; c.accent_color = "#E8341A" },
  drinks:   MenuCategory.find_or_create_by!(slug: "drinks")   { |c| c.name = "Drinks";   c.position = 2; c.accent_color = "#F5A623" },
  snacks:   MenuCategory.find_or_create_by!(slug: "snacks")   { |c| c.name = "Snacks";   c.position = 3; c.accent_color = "#FB7185" },
  desserts: MenuCategory.find_or_create_by!(slug: "desserts") { |c| c.name = "Desserts"; c.position = 4; c.accent_color = "#A78BFA" }
}
puts "  ✓ Menu categories: #{MenuCategory.count}"

# ------------------------------------------------------------ Menu items with real images
# Image strategy: each item has an ordered list of URLs, first that works wins.
# Unsplash for quality → Foodish API for category fallback → Picsum seeded for bulletproof.

def unsplash(id, w: 1200, h: 900)
  "https://images.unsplash.com/photo-#{id}?w=#{w}&h=#{h}&fit=crop&q=80"
end

def foodish(category)
  "https://foodish-api.com/images/#{category}/#{category}#{rand(1..30)}.jpg"
end

def picsum(seed, w: 1200, h: 900)
  "https://picsum.photos/seed/#{seed}/#{w}/#{h}"
end

menu_items = [
  # === FOOD ===
  {
    category: :food, name: "Signature Jollof Rice", price: 2500,
    desc: "Smoky Nigerian jollof rice with grilled chicken, fried plantain and house coleslaw.",
    featured: true, prep: 15,
    images: [
      unsplash("1604329760661-e71dc83f8f26"),
      foodish("rice"),
      picsum("jollof-rice")
    ]
  },
  {
    category: :food, name: "Blaze Burger", price: 2800,
    desc: "Double beef patty, aged cheddar, crispy bacon, house sauce on a toasted brioche bun.",
    featured: true, prep: 18,
    images: [
      unsplash("1568901346375-23c9450c58cd"),
      foodish("burger"),
      picsum("blaze-burger")
    ]
  },
  {
    category: :food, name: "Peppered Goat Meat", price: 3500,
    desc: "Tender goat meat in a fiery pepper sauce. A Nigerian classic. Served with rice or bread.",
    featured: true, prep: 22,
    images: [
      unsplash("1544025162-d76694265947"),
      picsum("goat-meat")
    ]
  },
  {
    category: :food, name: "Seafood Pasta Arrabbiata", price: 3800,
    desc: "Linguine with prawns, calamari, cherry tomatoes and a spicy garlic-tomato base.",
    prep: 16,
    images: [
      unsplash("1563379926898-05f4575a45d8"),
      foodish("pasta"),
      picsum("seafood-pasta")
    ]
  },
  {
    category: :food, name: "Grilled Tilapia", price: 4500,
    desc: "Whole tilapia grilled over open flame with Blaze spice rub. Served with plantain and pepper sauce.",
    prep: 25,
    images: [
      unsplash("1580959375944-abd7e991f971"),
      picsum("grilled-tilapia")
    ]
  },
  {
    category: :food, name: "Asun (Spicy Goat)", price: 3800,
    desc: "Roasted goat meat tossed in scotch bonnet, onions and peppers. Fire in the best way.",
    featured: true, prep: 20,
    images: [
      unsplash("1529042410759-befb1204b468"),
      picsum("asun")
    ]
  },
  {
    category: :food, name: "Chicken Shawarma Wrap", price: 2500,
    desc: "Grilled chicken, garlic mayo, pickled veg wrapped in a warm flatbread with cheese.",
    prep: 12,
    images: [
      unsplash("1565299507177-b0ac66763828"),
      picsum("shawarma")
    ]
  },
  {
    category: :food, name: "Fried Rice & Chicken", price: 2700,
    desc: "Nigerian-style fried rice with mixed veg, served with grilled chicken thigh.",
    prep: 15,
    images: [
      unsplash("1512003867696-6d5ce6835040"),
      foodish("rice"),
      picsum("fried-rice")
    ]
  },

  # === DRINKS ===
  {
    category: :drinks, name: "Blaze Smoothie", price: 1500,
    desc: "Mango, pineapple, ginger and lime. Our house signature, served iced.",
    featured: true,
    images: [
      unsplash("1553530666-ba11a7da3888"),
      picsum("blaze-smoothie")
    ]
  },
  {
    category: :drinks, name: "Hot Cafe Latte", price: 1200,
    desc: "Double-shot espresso with steamed milk and latte art on request.",
    images: [
      unsplash("1509042239860-f550ce710b93"),
      picsum("cafe-latte")
    ]
  },
  {
    category: :drinks, name: "Iced Chapman", price: 1300,
    desc: "The Nigerian classic: fizzy, fruity, garnished with cucumber and orange.",
    featured: true,
    images: [
      unsplash("1513558161293-cdaf765ed2fd"),
      picsum("chapman")
    ]
  },
  {
    category: :drinks, name: "Cold Brew Coffee", price: 1400,
    desc: "12-hour cold-extracted coffee, poured over a single giant ice cube.",
    images: [
      unsplash("1461023058943-07fcbe16d735"),
      picsum("cold-brew")
    ]
  },
  {
    category: :drinks, name: "Virgin Mojito", price: 1500,
    desc: "Fresh mint, lime, brown sugar, soda. Zero-proof, full flavour.",
    images: [
      unsplash("1551024709-8f23befc6f87"),
      picsum("mojito")
    ]
  },
  {
    category: :drinks, name: "Zobo Spritz", price: 1200,
    desc: "Hibiscus tea infused with pineapple, ginger and clove. Served chilled with lime.",
    images: [
      unsplash("1534353473418-4cfa6c56fd38"),
      picsum("zobo")
    ]
  },
  {
    category: :drinks, name: "Strawberry Frappé", price: 1800,
    desc: "Blended strawberry, cream and crushed ice. Topped with whip.",
    images: [
      unsplash("1572490122747-3968b75cc699"),
      picsum("strawberry-frappe")
    ]
  },
  {
    category: :drinks, name: "Espresso", price: 800,
    desc: "A single shot of our house blend. Quick, clean, honest.",
    images: [
      unsplash("1510707577719-ae7c14805e3a"),
      picsum("espresso")
    ]
  },

  # === SNACKS ===
  {
    category: :snacks, name: "Shareable Snack Box", price: 2200,
    desc: "Puff puff, spring rolls, chicken strips and house dip. Made for sharing between friends.",
    featured: true,
    images: [
      unsplash("1585238341710-4d3ff484cbd6"),
      picsum("snack-box")
    ]
  },
  {
    category: :snacks, name: "Crispy Chicken Wings (6pc)", price: 2800,
    desc: "Six wings tossed in your choice of BBQ, Buffalo, honey-lime or Blaze spicy.",
    images: [
      unsplash("1567620832903-9fc6debc209f"),
      picsum("chicken-wings")
    ]
  },
  {
    category: :snacks, name: "Suya Skewers (3pc)", price: 1800,
    desc: "Grilled beef skewers rolled in our house suya spice mix. Served with onion slivers.",
    images: [
      unsplash("1555939594-58d7cb561ad1"),
      picsum("suya")
    ]
  },
  {
    category: :snacks, name: "Loaded Fries", price: 1900,
    desc: "Hand-cut fries smothered in cheese sauce, suya spice, jalapeños and spring onion.",
    featured: true,
    images: [
      unsplash("1573080496219-bb080dd4f877"),
      picsum("loaded-fries")
    ]
  },
  {
    category: :snacks, name: "Puff Puff (6pc)", price: 900,
    desc: "Fluffy deep-fried dough balls dusted with cinnamon sugar. Served warm.",
    images: [
      unsplash("1486427944299-d1955d23e34d"),
      picsum("puff-puff")
    ]
  },
  {
    category: :snacks, name: "Plantain Chips & Dip", price: 1200,
    desc: "Thinly sliced ripe plantain fried crispy, served with a spicy mayo dip.",
    images: [
      unsplash("1606755962773-d324e0a13086"),
      picsum("plantain-chips")
    ]
  },

  # === DESSERTS ===
  {
    category: :desserts, name: "Chocolate Lava Cake", price: 2200,
    desc: "Warm molten chocolate cake with vanilla bean ice cream on the side.",
    featured: true, prep: 12,
    images: [
      unsplash("1617305855058-336d24456869"),
      foodish("dessert"),
      picsum("lava-cake")
    ]
  },
  {
    category: :desserts, name: "Mango Cheesecake", price: 2000,
    desc: "Creamy cheesecake on a buttery biscuit base, topped with fresh Nigerian mango.",
    images: [
      unsplash("1533134242443-d4fd215305ad"),
      foodish("dessert"),
      picsum("mango-cheesecake")
    ]
  },
  {
    category: :desserts, name: "Banana Split", price: 1800,
    desc: "Three scoops of ice cream, fresh banana, chocolate sauce, nuts and whipped cream.",
    images: [
      unsplash("1488900128323-21503983a07e"),
      picsum("banana-split")
    ]
  },
  {
    category: :desserts, name: "Tiramisu", price: 2200,
    desc: "Layered coffee-soaked lady fingers, mascarpone cream and cocoa dust.",
    images: [
      unsplash("1571877227200-a0d98ea607e9"),
      foodish("dessert"),
      picsum("tiramisu")
    ]
  },

  # === PRODUCTION-GRADE ADDITIONS: more Nigerian + international variety ===
  {
    category: :food, name: "Egusi & Pounded Yam", price: 3800,
    desc: "Rich egusi soup with ponmo, shaki and assorted meat, served with fresh pounded yam.",
    prep: 22,
    images: [ unsplash("1603133872878-684f208fb84b"), picsum("egusi-pounded-yam") ]
  },
  {
    category: :food, name: "Amala & Ewedu", price: 2500,
    desc: "Soft amala with smooth ewedu and spicy gbegiri. Served with your choice of meat.",
    prep: 18,
    images: [ unsplash("1592417817038-d13fd7342605"), picsum("amala-ewedu") ]
  },
  {
    category: :food, name: "Yam & Egg Sauce", price: 2200,
    desc: "Fried yam slices with a fiery egg-and-pepper sauce. Breakfast of champions.",
    prep: 12,
    images: [ unsplash("1604908176997-125f25cc6f3d"), picsum("yam-egg") ]
  },
  {
    category: :food, name: "Chicken Noodles", price: 2600,
    desc: "Stir-fried noodles with grilled chicken strips, carrots and pepper.",
    prep: 14,
    images: [ unsplash("1552611052-33e04de081de"), foodish("pasta"), picsum("chicken-noodles") ]
  },
  {
    category: :food, name: "Moi Moi & Stew", price: 2000,
    desc: "Steamed bean pudding with boiled egg, served with Nigerian pepper stew.",
    prep: 15,
    images: [ unsplash("1606787366850-de6330128bfc"), picsum("moi-moi") ]
  },
  {
    category: :drinks, name: "Tigernut Milk (Kunu Aya)", price: 1400,
    desc: "Creamy tigernut milk blended with dates and coconut. Dairy-free. Iced.",
    images: [ unsplash("1572490122747-3968b75cc699"), picsum("kunu-aya") ]
  },
  {
    category: :drinks, name: "Iced Zobo", price: 1100,
    desc: "Hibiscus tea infused with pineapple, ginger and clove. Served very cold.",
    images: [ unsplash("1534353473418-4cfa6c56fd38"), picsum("iced-zobo") ]
  },
  {
    category: :drinks, name: "Palm Wine (fresh)", price: 1600,
    desc: "Fresh, lightly fermented palm wine straight from the tapper. Available 6pm–10pm only.",
    images: [ unsplash("1513558161293-cdaf765ed2fd"), picsum("palm-wine") ]
  },
  {
    category: :snacks, name: "Meat Pie (2pc)", price: 1400,
    desc: "Flaky shortcrust pastry stuffed with spiced minced beef and potato.",
    images: [ unsplash("1565299543923-37dd37887442"), picsum("meat-pie") ]
  },
  {
    category: :snacks, name: "Chin Chin Tub", price: 1000,
    desc: "Crunchy sweet Nigerian chin chin. Great to share while waiting for your order.",
    images: [ unsplash("1558961363-fa8fdf82db35"), picsum("chin-chin") ]
  },
  {
    category: :snacks, name: "Akara & Pap", price: 1500,
    desc: "Golden bean cake fritters with warm pap. Pure comfort.",
    prep: 10,
    images: [ unsplash("1598515214211-89d3c73ae83b"), picsum("akara-pap") ]
  },
  {
    category: :desserts, name: "Coconut Ice Cream", price: 1500,
    desc: "House-churned coconut ice cream, three scoops, toasted coconut flakes.",
    images: [ unsplash("1488900128323-21503983a07e"), picsum("coconut-icecream") ]
  }
]

menu_items.each_with_index do |data, i|
  slug = data[:name].parameterize
  # Fresh lookup every iteration — survives any ID weirdness
  category = MenuCategory.find_by!(slug: data[:category].to_s)
  item = MenuItem.find_or_initialize_by(slug: slug)
  item.assign_attributes(
    name: data[:name],
    menu_category: category,
    description: data[:desc],
    price_kobo: data[:price] * 100,
    available: true,
    featured: data[:featured] || false,
    preparation_time: data[:prep]
  )
  item.save!
  result = attach_image(item, :image, data[:images], "item-#{slug}")
  print "  📸 [#{i + 1}/#{menu_items.length}] #{data[:name]}: #{result}\n"
end
puts "  ✓ Menu items: #{MenuItem.count}"

# ------------------------------------------------------------ Gaming consoles
console_mix = [
  { type: "PS5", count: 3 },
  { type: "PS5", count: 2 },
  { type: "PS4", count: 1 }
]
locations.each do |location|
  num = 1
  console_mix.each do |mix|
    mix[:count].times do
      GamingConsole.find_or_create_by!(location: location, number: num) do |c|
        c.console_type = mix[:type]
        c.active = true
      end
      num += 1
    end
  end
end
puts "  ✓ Gaming consoles: #{GamingConsole.count}"

# ------------------------------------------------------------ Gaming slots (next 7 days)
slot_price_kobo = 150_000 # ₦1,500 per 30min session
created_slots = 0
GamingConsole.active.includes(:location).find_each do |console|
  7.times do |day_offset|
    base = Time.zone.now.beginning_of_day + day_offset.days + 10.hours # starts 10am
    20.times do |i| # 10am → 8pm in 30-min slots
      starts = base + (i * 30).minutes
      next if starts < Time.current
      slot = GamingSlot.find_or_initialize_by(gaming_console: console, starts_at: starts)
      if slot.new_record?
        slot.assign_attributes(duration_minutes: 30, status: "open", price_kobo: slot_price_kobo)
        created_slots += 1 if slot.save
      end
    end
  end
end
puts "  ✓ Gaming slots: #{GamingSlot.count} (+#{created_slots} this run)"

# ------------------------------------------------------------ Cinema screens
screens = {
  main_big:   Screen.find_or_create_by!(location: main,  name: "Main Cinema") { |s| s.capacity = 24 },
  main_vip:   Screen.find_or_create_by!(location: main,  name: "VIP Lounge")  { |s| s.capacity = 10 },
  akure_big:  Screen.find_or_create_by!(location: akure, name: "Akure Screen") { |s| s.capacity = 20 },
  ondo_small: Screen.find_or_create_by!(location: ondo_town, name: "Ondo Screen") { |s| s.capacity = 16 }
}
puts "  ✓ Screens: #{Screen.count}"

# ------------------------------------------------------------ Screenings with posters
films = [
  {
    title: "Gangs of Lagos",
    synopsis: "Three best friends on the streets of Isale Eko must navigate their predetermined destinies in a world of crime and politics.",
    price: 3500,
    poster_urls: [
      unsplash("1485846234645-a62644f84728", w: 900, h: 1200),
      picsum("gangs-of-lagos", w: 900, h: 1200)
    ]
  },
  {
    title: "The Black Book",
    synopsis: "A bereaved deacon pursues the corrupt police gang that framed his son for kidnapping.",
    price: 3500,
    poster_urls: [
      unsplash("1478720568477-152d9b164e26", w: 900, h: 1200),
      picsum("black-book", w: 900, h: 1200)
    ]
  },
  {
    title: "Anikulapo: Rise of the Spectre",
    synopsis: "Myth, magic and destiny collide in a Yoruba afterlife tale from the world of Anikulapo.",
    price: 4000,
    poster_urls: [
      unsplash("1440404653325-ab127d49abc1", w: 900, h: 1200),
      picsum("anikulapo", w: 900, h: 1200)
    ]
  },
  {
    title: "Jagun Jagun",
    synopsis: "A young warrior rises through the ranks of an elite fighting force and discovers the price of vengeance.",
    price: 3500,
    poster_urls: [
      unsplash("1534528741775-53994a69daeb", w: 900, h: 1200),
      picsum("jagun-jagun", w: 900, h: 1200)
    ]
  },
  {
    title: "Brotherhood",
    synopsis: "Orphaned twins end up on opposite sides of the law — one joins the police, the other the underworld.",
    price: 3000,
    poster_urls: [
      unsplash("1518929458119-e5bf444c30f4", w: 900, h: 1200),
      picsum("brotherhood", w: 900, h: 1200)
    ]
  },
  {
    title: "King of Thieves",
    synopsis: "A Yoruba historical epic of power, justice, betrayal and the cost of ambition in a kingdom on the edge.",
    price: 3500,
    poster_urls: [
      unsplash("1489599849927-2ee91cede3ba", w: 900, h: 1200),
      picsum("king-of-thieves", w: 900, h: 1200)
    ]
  },
  {
    title: "The Woman King",
    synopsis: "Historical epic following Nanisca, leader of an all-female warrior unit in the Kingdom of Dahomey.",
    price: 4000,
    poster_urls: [
      unsplash("1542204165-65bf26472b9b", w: 900, h: 1200),
      picsum("woman-king", w: 900, h: 1200)
    ]
  },
  {
    title: "Breath of Life",
    synopsis: "A reclusive old man and a hopeful young man rediscover faith, friendship and purpose through music.",
    price: 3500,
    poster_urls: [
      unsplash("1598899134739-24c46f58b8c0", w: 900, h: 1200),
      picsum("breath-of-life", w: 900, h: 1200)
    ]
  },
  {
    title: "A Tribe Called Judah",
    synopsis: "A Nigerian matriarch and her five sons pull off the heist of a lifetime — for love and survival.",
    price: 3500,
    poster_urls: [
      unsplash("1485846234645-a62644f84728", w: 900, h: 1200),
      picsum("tribe-called-judah", w: 900, h: 1200)
    ]
  },
  {
    title: "Everybody Loves Jenifa",
    synopsis: "The return of Funke Akindele's beloved Jenifa — now running an NGO and still chaotic as ever.",
    price: 3000,
    poster_urls: [
      unsplash("1478720568477-152d9b164e26", w: 900, h: 1200),
      picsum("everybody-jenifa", w: 900, h: 1200)
    ]
  },
  {
    title: "House of Ga'a",
    synopsis: "The rise and fall of the most powerful prime minister in the Oyo Empire. Epic Yoruba historical drama.",
    price: 4000,
    poster_urls: [
      unsplash("1440404653325-ab127d49abc1", w: 900, h: 1200),
      picsum("house-of-gaa", w: 900, h: 1200)
    ]
  },
  {
    title: "Battle on Buka Street",
    synopsis: "Two feuding Nigerian mothers run rival food joints on the same street. Comedy gold from Funke Akindele.",
    price: 3000,
    poster_urls: [
      unsplash("1518929458119-e5bf444c30f4", w: 900, h: 1200),
      picsum("buka-street", w: 900, h: 1200)
    ]
  }
]

screens_list = screens.values
films.each_with_index do |film, film_idx|
  2.times do |variant|
    screen = screens_list[(film_idx + variant) % screens_list.length]
    starts = Time.zone.now.beginning_of_day + (film_idx / 2 + 1).days + (18 + variant * 2).hours
    slug = "#{film[:title].parameterize}-#{screen.id}-#{starts.to_i}"
    screening = Screening.find_or_create_by!(slug: slug) do |s|
      s.title = film[:title]
      s.synopsis = film[:synopsis]
      s.screen = screen
      s.starts_at = starts
      s.ends_at = starts + 2.hours
      s.price_kobo = film[:price] * 100
      s.available = true
    end
    result = attach_image(screening, :poster, film[:poster_urls], "poster-#{film[:title].parameterize}")
    print "  🎬 #{film[:title]} @ #{screen.name}: #{result}\n"
  end
end
puts "  ✓ Screenings: #{Screening.count}"

# ------------------------------------------------------------ TMDB real posters
# If TMDB_API_KEY is set, replace every screening's placeholder poster with
# the real one from The Movie Database. Idempotent — skips screenings that
# already have a tmdb_id cached.
if TmdbClient.configured?
  puts "  🎬 Fetching real posters from TMDB..."
  refreshed = 0
  Screening.find_each do |screening|
    next if screening.tmdb_id.present? && screening.poster.attached?
    begin
      match = TmdbClient.search_movie(screening.title)
      next unless match && match[:poster_path]

      url = TmdbClient.poster_url(match[:poster_path], size: "w780")
      io  = URI.parse(url).open(read_timeout: 15, "User-Agent" => "BlazeCafe/1.0")

      screening.update(tmdb_id: match[:id], tmdb_poster_path: match[:poster_path])
      screening.poster.purge if screening.poster.attached?
      screening.poster.attach(io: io, filename: "tmdb-#{match[:id]}.jpg", content_type: "image/jpeg")
      refreshed += 1
    rescue StandardError => e
      warn "   ⚠️  TMDB poster for '#{screening.title}': #{e.class}: #{e.message}"
    end
  end
  puts "  ✓ TMDB posters refreshed: #{refreshed}"
else
  puts "  ⊘ TMDB_API_KEY not set — using stock cinema photography. Set the key and re-run `rails db:seed` or `rails tmdb:refresh_posters` for real posters."
end

# ------------------------------------------------------------ Sample history (so dashboards + charts have data)
# Seeds realistic paid bookings, paid online orders, and offline sales spread
# across the last 30 days so the analytics dashboard lights up immediately.

customers = User.customer.to_a
ada   = User.find_by(email: "ada@example.ng")   || customers.first
kunle = User.find_by(email: "kunle@example.ng") || customers.last

# --- Paid bookings (gaming + cinema) across the last 30 days
if Booking.paid.count < 10
  [ ada, kunle ].compact.each do |user|
    5.times do |i|
      # Gaming booking
      slot = GamingSlot.where.not(id: Booking.pluck(:bookable_id)).available.order("RANDOM()").first
      if slot
        days_ago = rand(1..28)
        paid = days_ago.days.ago + rand(10..20).hours
        b = slot.bookings.build(seats: 1, notes: "Seeded", status: "confirmed")
        b.user = user
        b.payment_status = "paid"
        b.paid_at = paid
        b.created_at = paid
        if b.save
          b.update_columns(paid_at: paid, created_at: paid)
          slot.update(status: "reserved")
        end
      end
      # Cinema booking
      screening = Screening.order("RANDOM()").first
      if screening && screening.seats_remaining >= 2
        days_ago = rand(1..28)
        paid = days_ago.days.ago + rand(18..21).hours
        b = screening.bookings.build(seats: 2, notes: "Seeded", status: "confirmed")
        b.user = user
        b.payment_status = "paid"
        b.paid_at = paid
        b.created_at = paid
        if b.save
          b.update_columns(paid_at: paid, created_at: paid)
        end
      end
    end
  end
  puts "  ✓ Seeded paid bookings: #{Booking.paid.count}"
end

# --- Paid food orders
if Order.paid.count < 12
  customers.each do |user|
    3.times do
      days_ago = rand(0..28)
      paid = days_ago.days.ago + rand(8..22).hours
      order = user.orders.build(
        location: Location.active.order("RANDOM()").first,
        fulfillment: %w[pickup dine_in delivery].sample,
        payment_status: "paid",
        status: "completed",
        notes: "Seeded",
        delivery_address: "Oba Adesida Rd, Akure",
        delivery_city: "Akure",
        delivery_phone: user.phone
      )
      MenuItem.available.order("RANDOM()").limit(rand(1..4)).each do |item|
        order.order_items.build(menu_item: item, quantity: rand(1..3))
      end
      if order.save
        order.update_columns(paid_at: paid, created_at: paid)
      end
    end
  end
  puts "  ✓ Seeded paid orders: #{Order.paid.count}"
end

# --- Offline sales (walk-ins) over the last 30 days
if OfflineSale.count < 40
  admin_user = User.admin.first
  menu_items_list = MenuItem.available.to_a
  30.times do
    item = menu_items_list.sample
    sold = rand(0..29).days.ago + rand(9..22).hours
    OfflineSale.create!(
      menu_item: item,
      location: Location.active.order("RANDOM()").first,
      recorded_by: admin_user,
      quantity: rand(1..5),
      unit_price_kobo: item.price_kobo,
      payment_method: %w[cash card transfer pos].sample,
      sold_at: sold,
      notes: "Seeded"
    )
  end
  puts "  ✓ Seeded offline sales: #{OfflineSale.count}"
end

# ------------------------------------------------------------ Daily specials
# Image URLs are verified Unsplash photo IDs — same source as hero + menu seeds.
unsplash_url = ->(id, w: 1200, h: 900) {
  "https://images.unsplash.com/photo-#{id}?w=#{w}&h=#{h}&fit=crop&q=80&auto=format"
}

specials_data = [
  {
    name: "Ofada Rice Special",
    description: "House-made ofada rice with ayamase (designer stew), boiled egg and assorted meats. A Blaze classic — served hot.",
    kind: "food",
    price: 2000,
    original: 3500,
    slots: 25,
    hours: [ 11, 16 ],
    image: unsplash_url.call("1604329760661-e71dc83f8f26"),
    menu_item_slug: "signature-jollof-rice"
  },
  {
    name: "Abula Combo",
    description: "Amala + ewedu + gbegiri + assorted (ponmo, shaki, orisirisi). The real Yoruba thing.",
    kind: "food",
    price: 1800,
    original: 2800,
    slots: 20,
    hours: [ 12, 17 ],
    image: unsplash_url.call("1528605248644-14dd04022da1")
  },
  {
    name: "Blaze Burger Night",
    description: "Double beef patty + cheddar + bacon + curly fries + smoothie. Burger night — limited to 15 slots a day.",
    kind: "food",
    price: 3500,
    original: 4800,
    slots: 15,
    hours: [ 18, 22 ],
    image: unsplash_url.call("1568901346375-23c9450c58cd"),
    menu_item_slug: "blaze-burger"
  },
  {
    name: "Cinema Pair Deal",
    description: "Two seats + large popcorn + 2 drinks. Perfect date-night drop at the Main Cinema.",
    kind: "cinema",
    price: 6000,
    original: 8500,
    slots: 10,
    hours: [ 18, 23 ],
    image: unsplash_url.call("1489599849927-2ee91cede3ba")
  },
  {
    name: "Happy Hour Mocktails",
    description: "Buy any signature mocktail, get the second one half-price. Chapman, mojito, Blaze Smoothie — you pick.",
    kind: "drink",
    price: 1200,
    original: 2400,
    slots: 50,
    hours: [ 16, 19 ],
    image: unsplash_url.call("1551024709-8f23befc6f87")
  },
  {
    name: "Gaming Squad Hour",
    description: "Book 4 consoles for 1 hour at the price of 3. Roll deep with your squad — once a night only.",
    kind: "gaming",
    price: 4500,
    original: 6000,
    slots: 12,
    hours: [ 17, 21 ],
    image: unsplash_url.call("1550745165-9bc0b252726f")
  }
]

today_beginning = Time.current.beginning_of_day
specials_location = Location.active.first

specials_data.each do |data|
  starts = today_beginning + data[:hours][0].hours
  ends   = today_beginning + data[:hours][1].hours
  special = Special.find_or_initialize_by(slug: data[:name].parameterize)
  special.assign_attributes(
    name: data[:name],
    description: data[:description],
    kind: data[:kind],
    price_kobo: data[:price] * 100,
    original_price_kobo: data[:original] * 100,
    slots_total: data[:slots],
    slots_claimed: special.slots_claimed.to_i.positive? ? special.slots_claimed : rand(0..(data[:slots] / 3)),
    starts_at: starts,
    ends_at: ends,
    active: true,
    location: specials_location,
    menu_item: data[:menu_item_slug] ? MenuItem.find_by(slug: data[:menu_item_slug]) : nil,
    image_url: data[:image]
  )
  special.save!
end
puts "  ✓ Seeded specials: #{Special.count} (#{Special.where.not(image_url: nil).count} with images)"

# ------------------------------------------------------------ Loyalty stamp backfill
# Idempotent — find_or_create_by on (user, source, category) dedupes, so
# re-running on every deploy is safe.
if defined?(LoyaltyStamp)
  stamps_created = 0
  Booking.paid.includes(:user, :bookable).find_each do |b|
    next unless b.user && b.loyalty_category
    stamp = LoyaltyStamp.find_or_create_by!(user: b.user, source: b, category: b.loyalty_category) do |s|
      s.earned_at = b.paid_at || b.created_at
    end
    stamps_created += 1 if stamp.previously_new_record?
  end
  Order.paid.includes(:user).find_each do |o|
    next unless o.user
    stamp = LoyaltyStamp.find_or_create_by!(user: o.user, source: o, category: "food") do |s|
      s.earned_at = o.paid_at || o.created_at
    end
    stamps_created += 1 if stamp.previously_new_record?
  end
  puts "  ✓ Loyalty stamps: #{LoyaltyStamp.count} (+#{stamps_created} new)"
end

# ------------------------------------------------------------ Summary
puts "─" * 60
puts "🔥 BLAZE CAFE — seed complete"
puts "─" * 60
puts "  Locations:    #{Location.count}"
puts "  Categories:   #{MenuCategory.count}"
puts "  Menu items:   #{MenuItem.count} (#{MenuItem.joins(image_attachment: :blob).count} with images)"
puts "  Consoles:     #{GamingConsole.count}"
puts "  Gaming slots: #{GamingSlot.count}"
puts "  Screens:      #{Screen.count}"
puts "  Screenings:   #{Screening.count} (#{Screening.joins(poster_attachment: :blob).count} with posters)"
puts "  Users:        #{User.count} (#{User.admin.count} admin / #{User.customer.count} customers)"
puts "  Bookings:     #{Booking.count}"
puts "─" * 60
puts "Sign in:"
puts "  Admin    → admin@blazecafe.ng / blazeadmin123"
puts "  Customer → guest@blazecafe.ng / blazeguest123"
puts "─" * 60
