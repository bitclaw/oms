# Aceup Tech Assessment

This repository contains two projects:
- **frontend/**: React 19 + Vite application
- **backend/**: Ruby on Rails 7.2 API-only application (Ruby 3.3)

All services run in Docker using `docker-compose`.

## Prerequisites
- [Docker](https://www.docker.com/get-started)
- [Docker Compose](https://docs.docker.com/compose/)

## Quick Start

1. **Set up environment variables:**

```bash
make env.setup
```

2. **Build images and start all services:**

```bash
make build && make start
```

3. **Access the apps:**
- Frontend: [http://localhost:5173](http://localhost:5173)
- Backend (Rails API): [http://localhost:3000](http://localhost:3000)

4. **Database**
- Postgres runs in the `db` service.
- Default credentials (see `docker-compose.yml`):
  - Host: `db`
  - Username: `postgres`
  - Password: `postgres`
  - Database: `aceup_db`

5. **First-time Rails setup** (run in another terminal):

```bash
make db.init        # development database
make db.init.test   # test database
```

## Useful Commands

- **Rebuild images after dependency changes:**
  ```bash
  make build
  ```

- **Start the services:**
  ```bash
  make start
  ```

- **Stop all services:**
  ```bash
  make stop
  ```

- **Go into rails console:**
  ```bash
  make rails.c
  ```

- **Go into bash console:**
  ```bash
  make sh
  ```

- **Run migrations:**
  ```bash
  make db.migrate
  ```

- **Run backend tests:**
  ```bash
  make test
  ```

- **Run frontend tests:**
  ```bash
  make test.frontend
  ```

- **Run RuboCop:**
  ```bash
  make rubocop
  ```

- **Run ESLint:**
  ```bash
  make lint.frontend
  ```

## My Solution (Daniel)

### Approach

I followed the MVCS pattern the assessment calls for. Controllers are thin, they parse the request, call a service,
and render JSON. All business logic lives in service objects under `app/services/`.

### Key design decisions

- **Money as cents:** `amount_cents` is an integer column. Avoids floating point issues entirely. The frontend divides
  by 100 for display and multiplies by 100 on input.
- **Status as a constant:** `Order::STATUSES = %w[pending completed cancelled]`. One place to change it, validated at
  the model level with `validate_inclusion_of`.
- **Result struct in the service:** `Orders::CreateService` returns a `Result` struct with `success?`, `order`, and
  `errors`. Same idea as `Either` in Haskell, `Result<T, E>` in Rust, or `neverthrow` in TypeScript, failure is explicit
  in the return type, not an exception you might forget to rescue. The controller just checks `result.success?`.
- **Email on create:** `OrderMailer.order_created(order).deliver_now` is called from the service, not the controller. In
  production, you'd want `deliver_later` with a background job, but the assessment says no background jobs required.
- **CORS scoped to localhost:5173:** The CORS initializer only allows the local frontend origin. Easy to extend for
  production domains.
- **Styling with `oklch()`:** All colors in the frontend use the `oklch()` color space instead of hex or rgba.
  Perceptually uniform, lightness and chroma mean the same thing across hues, so adjusting a color for hover states or
  dark text is predictable. No more eyeballing hex values.

### Docker user mapping

The backend container runs as `CURRENT_UID:CURRENT_GID` (set in `.env`). This prevents permission issues on mounted
volumes when your local user differs from the container default. CI uses `sed -i` to replace these values in `.env`
before building.

### DB isolation

`database.yml` controls the database name per environment (`aceup_db_development`, `aceup_db_test`). There is no
`DATABASE_NAME` override in `docker-compose.yml` — that was intentionally removed so test runs always hit the test
database and never pollute development data.

### Scalability considerations

- `Order.ordered` sorts by `created_at desc`. There's no index on `created_at` right now fine for this scale, would add
  one before this hits any real load.
- `status` has no index either. If filtering by status becomes common (e.g. "show all pending orders"), that's a
  one-line migration to add.
- Email delivery is synchronous (`deliver_now`). For anything beyond a smallish app, this belongs in a background job
  (Sidekiq, GoodJob, etc.) so a slow mailer doesn't block the request.

### Security

Three dedicated CI jobs cover the security surface:

- `npm audit --omit=dev`: checks frontend production deps against the npm advisory database. Dev tooling
  vulnerabilities don't ship in the build artifact so they're excluded. Zero production vulnerabilities at time of
  submission.
- `bundler-audit`: checks `Gemfile.lock` against the Ruby Advisory Database for known CVEs in gems.
- `brakeman`: static analysis for Rails-specific vulnerabilities (SQL injection, XSS, mass assignment, etc.).

### What I'd add with more time

- Background job for email delivery
- Pagination on `GET /api/v1/orders`
- Order status transitions with validation (can't go from canceled back to pending)
- More frontend tests, especially for the Dialog submit/error flow
- A `show` and `update` endpoint to round out the CRUD
--

## Exercise for FullStack position

  Following the MVCS pattern (Model, View, Controller, Service), create a very simple order management system.

  **Frontend**

  - Create a Dashboard with at least 1 stat (# of orders created)
  - Create an order table | New Order button | New Order dialog
  - Refresh orders after new is created

  **Backend**

  - Orders crud
  - Send an email after order is created

## Exercise for Backend position; Unified People Sync (CRM + HRM)

## Overview

In this exercise, you will build a small **Ruby on Rails API** that ingests “Person” records coming from two external systems:

- **CRM** (e.g. sales/customer system)
- **HRM** (e.g. human resources system)

Each system has its own payload structure and is considered an external source of truth for different fields.

Your goal is to **normalize, merge, and persist people data** into a single internal representation while keeping the system clean, scalable, and performant.

This exercise is intentionally scoped to be completed in **4–5 hours**.

---

## Goals of the Exercise

We are primarily evaluating:

- Clean, readable, and maintainable code
- Sound object-oriented design and SOLID principles
- Appropriate use of design patterns
- Data modeling and database constraints
- Performance and scalability considerations
- Test quality and coverage
- Ability to explain trade-offs and future improvements

---

## Domain Description

### External Systems

You will receive people data from two sources:

#### 1. CRM
- Represents prospects or customers
- Example attributes:
  - `external_id`
  - `email`
  - `first_name`
  - `last_name`
  - `phone`
  - `company`
  - `updated_at`

#### 2. HRM
- Represents employees
- Example attributes:
  - `external_id`
  - `email`
  - `first_name`
  - `last_name`
  - `job_title`
  - `department`
  - `manager_email`
  - `start_date`
  - `updated_at`

Payload shapes may differ between systems.

You may define reasonable example payloads yourself.

---

## Internal Model

Your application should maintain a unified internal **Person** record.

A Person:
- Can be sourced from CRM, HRM, or both
- Should be **deduplicated**
- Should support **partial updates** from either system
- Must preserve source-specific identifiers

You are free to design the schema, but you should consider:
- How people are uniquely identified
- How external IDs are stored
- How conflicts between systems are resolved
- Which fields should be indexed

---

## Source of Truth Rules

When the same person exists in both systems, resolve conflicts using the following rules:

- **HRM is the source of truth for:**
  - `job_title`
  - `department`
  - `manager`
  - `start_date`

- **CRM is the source of truth for:**
  - `email`
  - `phone`
  - `company`

- Shared fields (`first_name`, `last_name`) may come from either system, but your logic should be consistent and deterministic.

---

## Functional Requirements

### Ingest Endpoints

Implement the following endpoints:

- `POST /ingest/crm/people`
- `POST /ingest/hrm/people`

Each endpoint:
- Accepts JSON payloads (single record or batch)
- Normalizes incoming data
- Creates or updates the corresponding Person
- Is **idempotent** (re-sending the same data must not create duplicates)

### Query Endpoints

Implement:

- `GET /people`
  - Supports filtering by:
    - email
    - source (crm, hrm)
    - department
  - Supports pagination

- `GET /people/:id`

---

## Technical Requirements

- Ruby on Rails
- Postgres as the database
- JSON or JSONB is allowed where appropriate
- Use database constraints and indexes to enforce integrity
- Controllers should be thin; business logic should live outside controllers
- The system should be designed so adding a **new data source** would require minimal changes

---

## Testing Requirements

- Include automated tests
- At minimum:
  - Unit tests for normalization / merge logic
  - One request spec per ingest endpoint
- Tests should be clear and meaningful rather than exhaustive

---

## Documentation

Include a `README` section explaining:

- Your overall approach and architecture
- Key design decisions
- How deduplication works
- How conflict resolution is implemented
- Performance and scalability considerations
- What you would improve or extend with more time

---

## Non-Requirements

- No authentication required
- No UI required
- No background jobs required (you may stub or describe them if relevant)
- No real external API calls

---

## Evaluation Notes

We value:
- Simplicity over over-engineering
- Clear boundaries and responsibilities
- Thoughtful trade-offs explained in writing
- Code that another engineer could confidently extend

Good luck, and feel free to make reasonable assumptions where needed.
