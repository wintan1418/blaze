# 🔥 Blaze Cafe — Deployment Guide (Hatchbox / Hetzner)

## How production database config now works

`config/database.yml` reads **`ENV["DATABASE_URL"]`** for production and lets
Hatchbox control the credentials. You don't need to set a separate password
env var — Hatchbox already put the full URL in `DATABASE_URL` when it
provisioned the Postgres database for this app.

Solid Cache, Solid Queue and Solid Cable all **share the primary database**
(tables live alongside the app tables). Rails creates `solid_cache_entries`,
`solid_queue_*`, `solid_cable_messages` etc on `db:migrate`.

## Required environment variables on the server

Set these in **Hatchbox → App → Environment**. Do NOT paste `DATABASE_URL` —
Hatchbox already sets that.

| Variable                | Example / value                          | Required |
|-------------------------|------------------------------------------|----------|
| `RAILS_MASTER_KEY`      | contents of `config/master.key`          | ✅ |
| `PAYSTACK_SECRET_KEY`   | `sk_test_xxx` (or `sk_live_xxx` when live) | ✅ |
| `PAYSTACK_PUBLIC_KEY`   | `pk_test_xxx`                             | ✅ |
| `TERMII_API_KEY`        | your Termii key                          | ✅ |
| `TERMII_SENDER_ID`      | e.g. `BLAZE` (must be approved)          | ✅ |
| `TERMII_LIVE`           | `true`                                   | ✅ |
| `TMDB_API_KEY`          | free v3 key from themoviedb.org/settings/api | recommended |
| `SMTP_*`                | SMTP credentials for Devise emails       | optional |
| `CLOUDINARY_URL`        | if you switch ActiveStorage to Cloudinary | optional |

## Post-build / post-deploy hook (Hatchbox)

Add this to **App → Settings → Deploy Hooks** (or the equivalent):

```bash
bundle exec rails db:prepare
bundle exec rails db:seed
```

- `db:prepare` creates the database if it doesn't exist, loads the schema,
  and runs any pending migrations. It's idempotent.
- `db:seed` is also idempotent — everything uses `find_or_create_by` /
  `find_or_initialize_by` so re-running is safe. Images are attached once
  (first run) and skipped on subsequent runs.

If you DON'T want seeds re-running on every deploy, just use `db:prepare`
alone — it only seeds on first-time database creation.

## Paystack webhook

In Paystack dashboard → API Keys & Webhooks, set the webhook URL to:

```
https://yourdomain/payments/webhook
```

Paystack will POST `charge.success` events there; `PaymentsController#webhook`
verifies the HMAC signature and finalizes payments asynchronously.

## TMDB (real movie posters)

Seeds include Nollywood film titles (Gangs of Lagos, The Black Book,
A Tribe Called Judah, etc). Without a TMDB key they render with stock
cinema photography. With a key, the seed and the
`rails tmdb:refresh_posters` rake task pull real posters from
themoviedb.org.

Get a free API key (takes 60 seconds):
1. Sign up at https://www.themoviedb.org/signup
2. Request an API key at https://www.themoviedb.org/settings/api (v3)
3. Set `TMDB_API_KEY=your_key` in Hatchbox env
4. SSH in and run: `bundle exec rails tmdb:refresh_posters`

To force a full re-fetch, run `bundle exec rails tmdb:clear` first.

## Termii SMS

- Your Termii sender ID must be **approved** before production sends work
- `TERMII_LIVE=true` makes the app hit the real API
- Set `TERMII_LIVE=false` for staging — the app will log messages but skip
  real delivery

## Rollback

On Hatchbox, the Deploys tab has a "Rollback" button that reverts to the
previous release without touching the database.

## Troubleshooting

### `PG::ConnectionBad: Peer authentication failed`
You're hitting Postgres over a Unix socket. `DATABASE_URL` must point to
a TCP host (Hatchbox does this by default). If you forked database.yml,
make sure the production block uses `url: <%= ENV["DATABASE_URL"] %>`.

### `fe_sendauth: no password supplied`
Your database.yml is overriding Hatchbox's URL with an explicit username
and an empty password env var. Remove hardcoded `username:` / `password:`
lines from the production block — let `DATABASE_URL` carry them.

### `PG::UndefinedTable: solid_cache_entries does not exist`
Run `bundle exec rails db:migrate` on the server. The Solid Cache/Queue/
Cable tables get created by their respective `migrations_paths`.

### Images on the dashboard are broken
Your seeds download imagery from Unsplash on first run. If Unsplash is
unreachable or times out, those attachments get skipped. Just re-run
`rails db:seed` and they'll fill in on the second attempt (idempotent).
