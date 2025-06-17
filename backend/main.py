from fastapi import FastAPI
from .database import engine

app = FastAPI()

@app.get("/")
def read_root():
    return {"message": "Hello from Family Planner backend"}

