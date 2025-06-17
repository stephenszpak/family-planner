# Family Planner

This repository contains a simple iOS Swift package and a Python backend for a family planner application.

## iOS App
The Swift package in this repo is a minimal starting point for a future iOS app. You can build it with `swift build`.

## Backend
The Python backend uses FastAPI and connects to a Postgres database hosted on AWS RDS.

### Database Configuration
The database connection defaults to the following host and port:

```
host: family-planner-db.c5e0yiaee08r.us-east-2.rds.amazonaws.com
port: 5432
```

Create a `.env` file with your database settings before running the backend. You can start by copying the provided example:

```bash
cp .env.example .env
```

Then edit `.env` and set `DB_USER`, `DB_PASSWORD`, `DB_NAME`, and any other values as needed.

### Running the Backend
Install dependencies:

```bash
pip install -r backend/requirements.txt
```

Start the server:

```bash
uvicorn backend.main:app --reload
```

