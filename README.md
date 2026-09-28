# Shipment Tracking Dashboard

A small shipment-tracking product for a fictional logistics company, built as a one-week full-stack take-home task. Customers can track shipments and submit enquiries without an account; staff can manage shipments, tracking events and enquiries.

All data is fictional and seeded for demonstration.

## Live demo

| Resource | Link |
|---|---|
| Live app | https://shipment-tracking-dashboard.onrender.com |
| Customer tracking | https://shipment-tracking-dashboard.onrender.com/tracking |
| Staff login | https://shipment-tracking-dashboard.onrender.com/users/log-in |
| Repository | https://github.com/jameswattsportfolio/shipment_tracking_dashboard |
| Walkthrough | `<WALKTHROUGH_URL>` |

> **First load may be slow.** Render's free tier may spin the service down after inactivity, so the first request can take around a minute.

## Demo credentials

| Email | Password |
|---|---|
| `staff@demo.com` | `demopassword123!` |

Demo tracking numbers:

| Number | Scenario | Status |
|---|---|---|
| `TRK-DEMO-001` | Normal shipment with three events | Collected |
| `TRK-DEMO-002` | Delivered shipment | Delivered |
| `TRK-DEMO-003` | Delayed shipment | Delayed |
| `TRK-DEMO-004` | Exception-style scenario | Cancelled |
| `TRK-DEMO-005` | New shipment with two events | Collected |

Two demo enquiries are also seeded: one open (`TRK-DEMO-003`) and one resolved (`TRK-DEMO-002`).

## Features

### Customer

- Public tracking with validation and not-found states.
- Shipment status, route, location, ETA and event timeline.
- Empty state for shipments without events.
- Delayed and exception-style messaging.
- Customer enquiries with category and message.
- Tracking searches reflected in the URL for bookmarking/sharing.

### Staff

- Authenticated dashboard with shipment search and status filtering.
- Create/edit shipments with server-side validation.
- Duplicate tracking numbers rejected.
- Append-only tracking events with timestamp, location, status and message.
- Staff-only shipment notes excluded from public responses.
- Enquiry management with open/resolved filtering and resolve/reopen actions.

## Tech stack

| Layer | Choice |
|---|---|
| Language / framework | Elixir, Phoenix 1.8 |
| Frontend | Phoenix LiveView, Tailwind CSS |
| Backend / API | Phoenix contexts and JSON REST API |
| Database | PostgreSQL via Ecto |
| Auth | `phx.gen.auth`, session cookies, Pbkdf2 |
| Hosting | Render (Docker + managed Postgres) |

LiveView provides the interactive UI without a separate frontend. Phoenix contexts keep business rules shared between the UI and API, while `phx.gen.auth` provides the authentication foundation.

## Local setup

**Prerequisites:** Elixir/Erlang/OTP (developed with Elixir 1.20) and PostgreSQL. No Node installation is required.

```bash
git clone https://github.com/jameswattsportfolio/shipment_tracking_dashboard.git
cd shipment_tracking_dashboard

# Check config/dev.exs if local PostgreSQL credentials differ.
# Defaults assume user "postgres" / password "postgres".

mix setup
mix phx.server
```

Open `http://localhost:4000`.

`mix setup` installs dependencies, creates/migrates the database, seeds demo data and builds assets.

| Command | Purpose |
|---|---|
| `mix ecto.setup` | Create DB, migrate and seed |
| `mix ecto.migrate` | Run pending migrations |
| `mix run priv/repo/seeds.exs` | Run seeds |
| `mix ecto.reset` | Drop, recreate, migrate and reseed |

The seed script is idempotent and creates the demo staff account, five shipments and two enquiries without duplicating existing records.

## Tests

```bash
mix test
```

The suite covers API behaviour, authentication/validation, public-data protection, event integrity and ordering, enquiry workflows, and the customer tracking LiveView flow. Generated `phx.gen.auth` tests cover login, logout, sessions and settings. Magic-link and self-registration UI tests were removed after those entry points were disabled.

## API

The JSON API sits alongside the LiveView UI and uses the same application contexts.

### Public

| Method | Path | Purpose |
|---|---|---|
| `GET` | `/api/shipments/:tracking_number` | Public shipment lookup with timeline |
| `POST` | `/api/enquiries` | Submit an enquiry |
| `POST` | `/api/auth/login` | Login and establish session cookie |
| `DELETE` | `/api/auth/logout` | End the session |

### Staff

Session cookie required; unauthenticated requests return `401`.

| Method | Path | Purpose |
|---|---|---|
| `GET` | `/api/staff/shipments` | List/search/filter shipments |
| `POST` | `/api/staff/shipments` | Create shipment |
| `PATCH` | `/api/staff/shipments/:id` | Update shipment |
| `POST` | `/api/staff/shipments/:id/events` | Append tracking event |
| `GET` | `/api/staff/enquiries` | List/filter enquiries |
| `PATCH` | `/api/staff/enquiries/:id` | Update enquiry status |

Successful responses use `{"data": ...}`; validation errors return `422`, missing records `404`, and unauthenticated staff requests `401`.

```bash
curl https://shipment-tracking-dashboard.onrender.com/api/shipments/TRK-DEMO-003

curl -c cookies.txt -X POST   https://shipment-tracking-dashboard.onrender.com/api/auth/login   -H "Content-Type: application/json"   -d '{"user":{"email":"staff@demo.com","password":"demopassword123!"}}'

curl -b cookies.txt   "https://shipment-tracking-dashboard.onrender.com/api/staff/shipments?status=delayed"
```

## Data model

- **shipments:** tracking number, status, route, location, service level, weight, package count, delivery dates and internal notes.
- **shipment_events:** timestamp, location, status and customer-readable message; events are append-only.
- **enquiries:** tracking number, category, message and open/resolved status.
- **users / users_tokens:** generated authentication tables.

## Deployment

The app runs on Render as a Docker web service with managed PostgreSQL. The release runs migrations, seeds the database and starts the application.

Production variables include `DATABASE_URL`, `SECRET_KEY_BASE`, `PHX_HOST`, `PHX_SERVER`, `PORT` and `POOL_SIZE`.

The free-tier web service can spin down after inactivity and the database is subject to Render's free-tier lifecycle policies. The idempotent seed script allows demo data to be recreated on a new database.

## Architecture and design decisions

**LiveView + REST API:** The UI talks directly to Phoenix contexts rather than its own API. The JSON API is independently usable and shares the same validation and business rules.

**Session-cookie authentication:** The API reuses the application's session authentication rather than introducing token authentication. API login/logout actions perform the session work without browser redirects.

**Public/staff data separation:** Public shipment responses explicitly whitelist fields, preventing internal notes from leaking through the API.

**Append-only events:** Events can be created/read but not edited/deleted, preserving shipment history.

**Status model:** Implemented statuses are `created`, `collected`, `out_for_delivery`, `delivered`, `delayed` and `cancelled`. The exception demo is represented as `cancelled` with an action-required event.

**Enquiries:** Tracking numbers are plain text rather than a foreign key, allowing enquiries even when a customer mistypes a number. Staff can change status but cannot overwrite the original message.

## Known limitations

- Shipment status and event creation are separate operations; I would link them in one transaction.
- Future-dated events are not currently blocked.
- ETA history is not stored.
- Delivered shipments do not require a delivery event.
- Staff tables use horizontal scrolling on smaller screens and some portrait tracking styling could be improved.
- Timestamps are displayed in UTC.
- Accessibility has not had a full automated audit.
- No pagination, login rate limiting or staff audit trail.
- Demo dates do not automatically advance over time.
- Some unused `phx.gen.auth` functionality remains.
- No CI pipeline or Docker Compose setup.

The project prioritised a complete, dependable end-to-end application within the one-week timeframe rather than adding stretch features before the core workflows were working.
