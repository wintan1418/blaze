# 🔥 Blaze Cafe

Full-stack Rails 8 app for **Blaze Cafe** — a premium entertainment + dining venue in Ondo State, Nigeria. Food, drinks, PlayStation gaming and private cinema, all under one roof.

Public site + booking platform + hand-rolled admin + runtime site customization.

## Stack

- **Rails** 8.1 · **Ruby** 3.4 · **PostgreSQL** 16
- **Hotwire** (Turbo + Stimulus)
- **Tailwind CSS v4** via `cssbundling-rails`
- **JavaScript** via `jsbundling-rails` + esbuild
- **Devise + Pundit** for auth & roles (`customer`, `staff`, `admin`)
- **Hand-rolled admin** at `/admin` — not ActiveAdmin
- **ActiveStorage + Cloudinary** for images
- **Solid Queue / Cache / Cable** (Rails 8 built-ins)
- **Paystack** for payments
- **Termii** for SMS notifications
- **Kamal 2** for deployment

## Features

- Public site with menu, gaming, cinema, locations, about, contact
- Booking flow for PlayStation sessions + cinema screenings
- Full admin dashboard: CRUD for everything + stats
- **Runtime site customization** at `/admin/settings` — brand colors, fonts, logo, hero copy, section toggles, all without a rebuild
- **Hero slide CRUD** — manage the rotating hero reel from `/admin/hero_slides`
- Real food photography via Unsplash + Foodish API
- Dismissable toast notifications, styled pagination, polished dark theme

## Quick start

```bash
git clone git@github.com:wintan1418/blaze.git
cd blaze
bundle install
yarn install
cp .env.example .env   # then fill in your keys

bin/rails db:create db:migrate db:seed
bin/dev                 # starts Rails + JS watcher + CSS watcher
```

Visit <http://localhost:3000>.

**Seeded accounts:**
- Admin: `admin@blazecafe.ng` / `blazeadmin123`
- Customer: `guest@blazecafe.ng` / `blazeguest123`

## Environment

See `.env.example` for all required keys:

- `PAYSTACK_SECRET_KEY` / `PAYSTACK_PUBLIC_KEY` — payments
- `TERMII_API_KEY` / `TERMII_SENDER_ID` / `TERMII_LIVE` — SMS

## Commands

```bash
bin/dev                 # start everything
bin/rails s             # Rails only
bin/rails db:migrate    # run migrations
bin/rails db:seed       # seed (idempotent — safe to re-run)
bin/rails c             # console
bin/rails test          # tests
bin/rubocop             # lint
bin/brakeman            # security scan
```

## Project docs

- `CLAUDE.md` — conventions, architecture, deployment checklist
- `blaze_cafe_build_doc.docx` — original spec

## License

Proprietary — © 2026 Blaze Cafe.
