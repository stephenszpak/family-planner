import os
import uuid
from datetime import datetime, timedelta

from fastapi import FastAPI, Depends, HTTPException
from pydantic import BaseModel, EmailStr
from jose import jwt
from passlib.context import CryptContext
from sqlalchemy.orm import Session

from .database import engine, get_db
from .models import Base, User

app = FastAPI()

SECRET_KEY = os.getenv("SECRET_KEY", "secret")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_DAYS = 180
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

Base.metadata.create_all(bind=engine)

class RegisterRequest(BaseModel):
    username: str
    email: EmailStr
    password: str


class LoginRequest(BaseModel):
    email: EmailStr
    password: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"


def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)


def get_password_hash(password: str) -> str:
    return pwd_context.hash(password)


def create_access_token(data: dict, expires_delta: timedelta) -> str:
    to_encode = data.copy()
    expire = datetime.utcnow() + expires_delta
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)


def send_verification_email(email: str, token: str) -> None:
    link = f"http://localhost:8000/verify/{token}"
    print(f"Verification email to {email}: {link}")

@app.get("/")
def read_root():
    return {"message": "Hello from Family Planner backend"}


@app.post("/register")
def register(req: RegisterRequest, db: Session = Depends(get_db)):
    if db.query(User).filter(User.email == req.email).first():
        raise HTTPException(status_code=400, detail="Email already registered")
    if db.query(User).filter(User.username == req.username).first():
        raise HTTPException(status_code=400, detail="Username taken")
    hashed_pw = get_password_hash(req.password)
    token = str(uuid.uuid4())
    user = User(
        username=req.username,
        email=req.email,
        hashed_password=hashed_pw,
        verification_token=token,
    )
    db.add(user)
    db.commit()
    send_verification_email(req.email, token)
    return {"message": "User created. Please verify your email."}


@app.get("/verify/{token}")
def verify_email(token: str, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.verification_token == token).first()
    if not user:
        raise HTTPException(status_code=404, detail="Invalid verification token")
    user.is_verified = True
    user.verification_token = None
    db.commit()
    return {"message": "Email verified"}


@app.post("/login", response_model=TokenResponse)
def login(req: LoginRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == req.email).first()
    if not user or not verify_password(req.password, user.hashed_password):
        raise HTTPException(status_code=400, detail="Incorrect email or password")
    if not user.is_verified:
        raise HTTPException(status_code=400, detail="Email not verified")
    token = create_access_token(
        data={"sub": str(user.id)},
        expires_delta=timedelta(days=ACCESS_TOKEN_EXPIRE_DAYS),
    )
    return {"access_token": token, "token_type": "bearer"}

