# 🔥 Blaze Cafe — Deployment Guide (Hatchbox / Hetzner)

## The DB connection error you're hitting

```
PG::ConnectionBad: ... FATAL: Peer authentication failed for user "blaze_cafe"
```

**What it means:** Rails tried to connect to PostgreSQL over a Unix socket
(no `host` specified). Postgres's default socket rule is `peer` auth, which
requires the OS username to match the DB username. Your app runs as `deploy`
but tries to connect as `blaze_cafe` → peer auth fails.

**Fix (already applied in this commit):** `config/database.yml` now forces
the production primary to connect over TCP to `localhost` by default, which
bypasses peer auth and uses md5/scram password auth instead.

## Required environment variables on the server

Set these in the **Hatchbox → App → Environment** tab:

| Variable                          | Example / value                          | Required |
|-----------------------------------|------------------------------------------|----------|
| `RAILS_MASTER_KEY`                | contents of `config/master.key`          | ✅ |
| `BLAZE_CAFE_DATABASE_PASSWORD`    | the postgres password for `blaze_cafe` user | ✅ |
| `DB_HOST`                         | `localhost` (default) or external DB host | optional |
| `DB_PORT`                         | `5432` (default)                         | optional |
| `PAYSTACK_SECRET_KEY`             | `sk_live_xxx` when going live            | ✅ |
| `PAYSTACK_PUBLIC_KEY`             | `pk_live_xxx`                             | ✅ |
| `TERMII_API_KEY`                  | your Termii key                          | ✅ |
| `TERMII_SENDER_ID`                | e.g. `BLAZE` (max 11 chars, must be approved) | ✅ |
| `TERMII_LIVE`                     | `true`                                   | ✅ |
| `SMTP_*`                          | SMTP credentials for Devise emails       | optional |
| `CLOUDINARY_URL`                  | if you switch ActiveStorage to Cloudinary | optional |

## One-time database setup on the server

Run these **on the Hetzner box** as root or via `sudo -u postgres psql`:

```bash
sudo -u postgres psql <<'SQL'
CREATE USER blaze_cafe WITH PASSWORD 'REPLACE_WITH_STRONG_PASSWORD';
CREATE DATABASE blaze_cafe_production OWNER blaze_cafe;
CREATE DATABASE blaze_cafe_production_cache OWNER blaze_cafe;
CREATE DATABASE blaze_cafe_production_queue OWNER blaze_cafe;
CREATE DATABASE blaze_cafe_production_cable OWNER blaze_cafe;
ALTER USER blaze_cafe CREATEDB;
SQL
```

Then set `BLAZE_CAFE_DATABASE_PASSWORD` to the password you used above.

## If you still see peer auth errors after the above

Open `/etc/postgresql/16/main/pg_hba.conf` and make sure the `host` rules
for `127.0.0.1/32` and `::1/128` use `md5` or `scram-sha-256` (not `peer`):

```
# TYPE  DATABASE        USER            ADDRESS                 METHOD
local   all             all                                     peer
host    all             all             127.0.0.1/32            scram-sha-256
host    all             all             ::1/128                 scram-sha-256
```

Then reload: `sudo systemctl reload postgresql`

## First deploy checklist

1. ✅ Set all required env vars above in Hatchbox
2. ✅ Create the Postgres user + 4 databases (commands above)
3. ✅ Point DNS for `blazecafe.ng` (or your domain) at the Hetzner box
4. ✅ In Hatchbox → SSL, enable Let's Encrypt
5. ✅ Trigger deploy
6. After successful first deploy, SSH in and run:

   ```bash
   cd /home/deploy/Blaze-cafe/current
   RAILS_ENV=production bundle exec rails db:seed
   ```

7. Sign in at `https://yourdomain/users/sign_in`:
   - `admin@blazecafe.ng` / `blazeadmin123` (change this immediately)

## Paystack webhook

In Paystack dashboard → API Keys & Webhooks, set the webhook URL to:

```
https://yourdomain/payments/webhook
```

Paystack will POST `charge.success` events there; the `PaymentsController#webhook`
verifies the HMAC signature and finalizes payments asynchronously.

## Termii SMS

- Your Termii sender ID must be **approved** (pending senders won't deliver)
- Test SMS are free during development, production sends use credits
- `TERMII_LIVE=true` makes the app hit the real API. Set `false` for staging
  to log but not send.

## Rollback

On Hatchbox: the Deploys tab has a "Rollback" button that reverts to the
previous release without touching the database.
