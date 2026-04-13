# CLAUDE.md — Blaze Cafe

Full-stack cafe + entertainment booking app for **Blaze Cafe**, Ondo State, Nigeria. The business offers food, drinks, PlayStation gaming, and private cinema screenings. This app is the public website, online menu, booking platform, and admin backend.

## Stack

- **Rails** 8.1.3, **Ruby** 3.4.3
- **PostgreSQL** 16 (dev user: `wintan`, peer auth)
- **Hotwire** — Turbo + Stimulus (primary interactivity)
- **Tailwind CSS** via `cssbundling-rails` (NOT `tailwindcss-rails` — we use the Node build)
- **JavaScript** via `jsbundling-rails` + esbuild (NOT importmap — we need to bundle motion libs)
- **Auth** — Devise + Pundit (roles: `customer`, `staff`, `admin`)
- **Admin** — **hand-rolled** Tailwind admin at `/admin` (NOT ActiveAdmin — must be on-brand)
- **File storage** — ActiveStorage + Cloudinary (production) / local disk (dev)
- **Background jobs** — Solid Queue
- **Caching** — Solid Cache
- **Cable** — Solid Cable
- **Notifications** — Noticed (email via BookingMailer)
- **Deploy** — Kamal 2 → VPS at `blazecafe.ng` (do NOT deploy without user approval)

## Key Commands

```bash
bin/dev                 # start Rails + JS watcher + CSS watcher (Procfile.dev)
bin/rails s             # Rails server only
bin/rails db:migrate    # run migrations
bin/rails db:seed       # seed initial data
bin/rails db:reset      # drop, create, migrate, seed
bin/rails c             # console
bin/rails test          # run tests
bin/rubocop             # lint
bin/brakeman            # security scan
kamal deploy            # production deploy (user approval required)
```

## Architecture

### Models
- `User` (Devise) — `role` enum: `customer`, `staff`, `admin`
- `Location` — branches across Ondo State (friendly_id slug)
- `MenuCategory` — food / drinks / etc. (friendly_id slug, position)
- `MenuItem` — belongs_to category, `has_one_attached :image`, `price_kobo:integer`
- `GamingConsole` — belongs_to location, has_many gaming_slots
- `GamingSlot` — belongs_to console, `starts_at`, `duration_minutes`, `status`, `price_kobo`
- `Screen` — belongs_to location, `capacity`
- `Screening` — belongs_to screen, `title`, `starts_at`, `ends_at`, `price_kobo`, `poster`
- `Booking` — **polymorphic** (`bookable` = GamingSlot | Screening), belongs_to user
- `Review` — polymorphic `reviewable`, belongs_to user, rating + body

### Routing
- Public: `/` (home), `/menu`, `/menu/:slug`, `/gaming`, `/cinema`, `/locations`, `/about`, `/contact`
- Auth: `/users/sign_in`, `/users/sign_up`
- Bookings: `/bookings` (user dashboard), nested booking creation under `/gaming_slots/:id` and `/screenings/:id`
- Admin: `/admin/*` — requires `admin` role via Pundit

### Hotwire patterns
- **Turbo Frames** wrap booking forms — inline load without redirect
- **Turbo Streams** broadcast slot availability changes in real time
- **Stimulus** controllers for tilt, scroll-reveal, marquee, magnetic-button, count-up, date-picker

## Conventions — READ BEFORE WRITING CODE

### Currency (important — deviates from build doc)
- Prices stored as `price_kobo:integer` (Nigerian kobo, 1 Naira = 100 kobo)
- NEVER use `decimal` for money. Integer-kobo avoids rounding bugs and aligns with Paystack/Flutterwave conventions
- Display via `Money.format(kobo)` helper → renders as `₦2,500`
- Forms accept Naira input (not kobo) and convert on save

### Styling
- **Tailwind only** — no custom CSS files except `application.tailwind.css` for `@layer` primitives
- Dark theme baseline: `bg-zinc-950`, `text-zinc-100`
- Brand colors defined in `tailwind.config.js`:
  - `blaze-red`: `#E8341A`
  - `blaze-amber`: `#F5A623`
  - `blaze-ink`: `#0A0A0B` (near-black background)
- Font stack: self-hosted `Space Grotesk` (display) + `Inter` (body) via `@font-face` — NO Google Fonts CDN in production
- Fire-gradient utility: `bg-gradient-to-r from-blaze-red via-orange-500 to-blaze-amber`

### Authorization
- Pundit policies in `app/policies/`
- Every admin controller inherits from `Admin::BaseController` which `before_action :authorize_admin!`
- User-facing controllers use `authorize @record` explicitly where needed

### Slugs
- `friendly_id` on `Location`, `MenuCategory`, `MenuItem` — use `find` with slug in controllers

### Turbo
- Every form that mutates data must have `data: { turbo_confirm: "..." }` for destructive actions
- Use `turbo_stream.replace` for real-time updates, never full re-renders

### Testing
- `rails test` — minitest (Rails default, already set up)
- Seed data must be idempotent — `db:seed` can be re-run without duplicates (use `find_or_create_by!`)

## Environment Variables (dev uses `.env` via dotenv-rails if added)

- `DATABASE_URL` (optional — defaults to local socket)
- `CLOUDINARY_URL` (production images)
- `RAILS_MASTER_KEY`
- `SMTP_ADDRESS`, `SMTP_USERNAME`, `SMTP_PASSWORD` (booking emails)

## Git & Commit Rules

**NEVER add a `Co-Authored-By: Claude ...` trailer to commits.** The user wants clean commit history attributed solely to themselves. Also omit the "🤖 Generated with Claude Code" footer. Write plain, conventional commit messages — that's it.

Branch strategy: work on `main` directly for this greenfield project until the user says otherwise.

## Design Brief — "Blazing" for Gen Z

The name is Blaze. The UI must feel like it. Principles:

- **Dark, editorial, confident** — massive headlines, generous whitespace, no cute illustrations
- **Kinetic** — scroll-triggered reveals, tilt cards, magnetic buttons, marquee strips, count-up stats
- **Fire as accent** — red→orange→amber gradients as brand punctuation, never dominant
- **Image-forward** — big food/cinema/gaming photography, price as display numeral
- **Motion budget** — animations must degrade gracefully on `prefers-reduced-motion`

Do NOT ship: glassmorphism blur everywhere, stock gradients, generic bootstrap vibes, light theme as default.

## Current Build Order

See `blaze_cafe_build_doc.docx` at repo root for the original spec. Implementation phases tracked in the task list — phases 1→6 (Foundation → Admin → Public Site → Bookings → Polish → Deploy).

## Deployment checklist (Phase 6 — waiting on user)

`config/deploy.yml` still has placeholders. Before `kamal setup`, fill in:

- [ ] `servers.web` — real VPS IP(s)
- [ ] `registry.server` / `registry.username` — Docker Hub or GHCR creds
- [ ] `proxy.host` — `blazecafe.ng` (uncomment ssl block)
- [ ] `accessories.db` — Postgres 16 container (uncomment, set host + volume)
- [ ] `.kamal/secrets` — `RAILS_MASTER_KEY`, `BLAZE_CAFE_DATABASE_PASSWORD`, `KAMAL_REGISTRY_PASSWORD`, `POSTGRES_PASSWORD`, Cloudinary + SMTP creds
- [ ] Update `config/database.yml` production block if DB host differs
- [ ] Set `config.force_ssl = true` in `config/environments/production.rb` when SSL proxy is on
- [ ] Smoke test Dockerfile build locally: `docker build -t blaze_cafe .`

Only then run `bin/kamal setup` and subsequently `bin/kamal deploy`. DO NOT push without explicit approval from the user.
