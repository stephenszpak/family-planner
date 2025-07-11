# Family Planner

This repository contains a simple iOS Swift package and a Python backend for a family planner application.

## iOS App
The Swift package in this repo is a minimal starting point for a future iOS app. After logging in, the app now presents a basic home dashboard with placeholder widgets for a calendar and a task list. You can build it with `swift build`.

## Backend
The Python backend uses FastAPI and connects to a Postgres database hosted on Render.com.

### Database Configuration
The database connection defaults to the following host and port:

```
host: dpg-d19bsdadbo4c73d56f2g-a
port: 5432
```


Create a `.env` file with your database settings before running the backend. You can start by copying the provided example:

```bash
cp .env.example .env
```

Then edit `.env` and set `DB_USER`, `DB_PASSWORD`, `DB_NAME`, and any other values as needed.

Set the `DB_USER`, `DB_PASSWORD`, and `DB_NAME` environment variables to match your database credentials before running the backend.


### Running the Backend
Install dependencies:

```bash
pip install -r backend/requirements.txt
```

This installs FastAPI along with `email-validator`, which is required for Pydantic's `EmailStr` type used in the API models.

Start the server:

```bash
uvicorn backend.main:app --reload
```

