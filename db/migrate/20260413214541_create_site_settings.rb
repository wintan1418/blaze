class CreateSiteSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :site_settings do |t|
      # Identity
      t.string  :site_name,         default: "Blaze Cafe",                     null: false
      t.string  :tagline,           default: "Where Good Times Come Alive",    null: false
      t.text    :meta_description
      t.string  :logo_mark,         default: "B",                              null: false
      t.string  :logo_wordmark,     default: "BLAZE.",                         null: false

      # Contact
      t.string  :contact_email,     default: "hello@blazecafe.ng"
      t.string  :contact_phone,     default: "+234 812 000 1000"

      # Socials
      t.string  :instagram_url
      t.string  :tiktok_url
      t.string  :x_url
      t.string  :whatsapp_url

      # Brand colors (hex, without #)
      t.string  :primary_color,     default: "E8341A", null: false # blaze-red
      t.string  :ember_color,       default: "FF5A1F", null: false # blaze-ember
      t.string  :accent_color,      default: "F5A623", null: false # blaze-amber
      t.string  :ink_color,         default: "0A0A0B", null: false # blaze-ink (bg)
      t.string  :ash_color,         default: "13131A", null: false # blaze-ash (cards)
      t.string  :smoke_color,       default: "1C1C24", null: false # blaze-smoke (inputs)

      # Fonts (Google Font family names)
      t.string  :display_font,      default: "Space Grotesk", null: false
      t.string  :body_font,         default: "Inter",         null: false

      # Hero section
      t.string  :hero_eyebrow,         default: "Blaze · 001"
      t.string  :hero_live_label,      default: "Open now"
      t.string  :hero_headline_line1,  default: "Taste"
      t.string  :hero_headline_line2,  default: "the fire."
      t.string  :hero_headline_accent, default: "fire" # the word inside line2 that gets fire-text styling
      t.text    :hero_subtitle,        default: "Chef-cooked African plates, ice-cold drinks, PlayStation sessions and private cinema — across Ondo State."
      t.string  :hero_cta_primary,     default: "Explore the menu"
      t.string  :hero_cta_secondary,   default: "Book a session"
      t.string  :hero_footer_mark,     default: "Est. Ondo State · 2026"

      # Vibe section
      t.string  :vibe_eyebrow,      default: "The vibe"
      t.string  :vibe_headline,     default: "This is how we come alive."
      t.text    :vibe_body,         default: "Friends laughing over jollof. Controllers in hand. A cold drink between rounds. Blaze Cafe isn't just a place — it's how Ondo State unwinds."

      # Featured dishes section
      t.string  :dishes_eyebrow,    default: "Signature dishes"
      t.string  :dishes_headline,   default: "Plates that slap."

      # Experiences section
      t.string  :experiences_eyebrow,  default: "Experiences"
      t.string  :experiences_headline, default: "Four ways to come alive."

      # Testimonial
      t.text    :testimonial_quote,  default: "The jollof hits different. The PS5 is clean. The cinema room is bigger than my bedroom. Blaze is the move in Ondo, period."
      t.string  :testimonial_author, default: "Ada, regular since day one"

      # CTA band
      t.string  :cta_headline,       default: "Ready to come alive?"
      t.text    :cta_body,           default: "Book a PlayStation session, reserve cinema seats, or just swing by. We're open daily from 10am."

      # About page
      t.string  :about_eyebrow,     default: "About"
      t.string  :about_headline,    default: "The story behind the flame."
      t.text    :about_body,        default: "Blaze Cafe started on a school campus in Ondo State as a single idea: a place where students, creatives and everyone in between could eat well, drink well, play on the best consoles and catch a film — all under one roof.\n\nToday we serve chef-cooked plates, craft drinks, 30-minute PlayStation sessions, and intimate cinema screenings. Everything we do is guided by one thing: good times that come alive.\n\nWe're growing across Ondo State — bringing the same energy, the same hospitality, and the same flame to every location."

      # Contact page
      t.string  :contact_eyebrow,   default: "Contact"
      t.string  :contact_headline,  default: "Talk to us."
      t.text    :contact_body,      default: "For bookings, private events, or just to say hi — reach us on any of the channels below."

      # Footer
      t.text    :footer_tagline,    default: "Where good times come alive. Premium food, drinks, PlayStation gaming and private cinema — all under one roof across Ondo State."

      # Section toggles (JSON)
      t.jsonb   :sections,          default: {}, null: false

      t.timestamps
    end
  end
end
