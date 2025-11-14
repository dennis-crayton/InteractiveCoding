# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

## Running locally with Docker (recommended)

This project includes a `Dockerfile`, `docker-compose.yml`, and helper scripts to make local development easier on Windows.

Quick steps (Windows PowerShell):

1. Run the PowerShell permission helper (only needed once after cloning or if you get permission errors):

```powershell
./scripts/fix-permissions.ps1
```

2. Start the app with Docker Compose (this uses the image entrypoint which ensures runtime dirs exist):

```powershell
docker compose up --build
# or to start detached
docker compose up --build -d
```

3. Open http://localhost:3000

Notes
- The `entrypoint.sh` script ensures `tmp`, `log`, and `storage` directories exist before delegating to the upstream `bin/docker-entrypoint` which prepares the DB.
- The `scripts/fix-permissions.ps1` helper sets Windows ACLs so the non-root `rails` user inside the container can write to the mounted directories. This avoids running the container as root.

Common commands

```powershell
# Tail logs
docker compose logs -f app

# Run migrations
docker compose run --rm app bin/rails db:migrate

# Open rails console
docker compose run --rm app bin/rails console

# Run tests
docker compose run --rm app bin/rails test
```

