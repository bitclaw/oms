# Aceup Tech Assessment

This repository contains two projects:
- **frontend/**: React 19 + Vite application
- **backend/**: Ruby on Rails 7.2 API-only application (Ruby 3.2)

All services run in Docker using `docker-compose`.

## Prerequisites
- [Docker](https://www.docker.com/get-started)
- [Docker Compose](https://docs.docker.com/compose/)

## Quick Start

1. **Build and start all services:**

```bash
make build
```

2. **Access the apps:**
- Frontend: [http://localhost:5173](http://localhost:5173)
- Backend (Rails API): [http://localhost:3000](http://localhost:3000)

3. **Database**
- Postgres runs in the `db` service.
- Default credentials (see `docker-compose.yml`):
  - Host: `db`
  - Username: `postgres`
  - Password: `postgres`
  - Database: `aceup_db`

4. **First-time Rails setup** (run in another terminal):

```bash
make db.init
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
