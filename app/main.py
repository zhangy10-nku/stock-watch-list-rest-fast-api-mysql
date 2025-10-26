from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy import create_engine, Column, Integer, String, Float, DateTime
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session
from pydantic import BaseModel
from typing import List, Optional
import os
from datetime import datetime
import aiohttp
import jwt
import logging

# Configure logging
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

# Database setup
DATABASE_URL = os.getenv("DATABASE_URL", "mysql+pymysql://stockuser:stockpass@localhost:3306/stockwatchlist")
engine = create_engine(DATABASE_URL, echo=True)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# Google OAuth configuration
GOOGLE_CLIENT_ID = os.getenv("GOOGLE_CLIENT_ID")
GOOGLE_CLIENT_SECRET = os.getenv("GOOGLE_CLIENT_SECRET")

if not GOOGLE_CLIENT_ID:
  raise ValueError("GOOGLE_CLIENT_ID environment variable must be set")

# Security schemes
http_bearer = HTTPBearer()

# FastAPI app
app = FastAPI(
  title="Stock Watchlist API", 
  version="1.0.0",
  debug=True  # Enable debug mode
)

# Database Models
class Stock(Base):
  __tablename__ = "stocks"
  
  id = Column(Integer, primary_key=True, index=True)
  symbol = Column(String(10), unique=True, index=True, nullable=False)
  name = Column(String(255), nullable=False)
  price = Column(Float, nullable=True)
  user_id = Column(String(255), index=True, nullable=False)
  created_at = Column(DateTime, default=datetime.utcnow)
  updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

# Pydantic Models
class StockBase(BaseModel):
  symbol: str
  name: str
  price: Optional[float] = None

class StockCreate(StockBase):
  pass

class StockUpdate(BaseModel):
  name: Optional[str] = None
  price: Optional[float] = None

class StockResponse(StockBase):
  id: int
  user_id: str
  created_at: datetime
  updated_at: datetime
  
  class Config:
    from_attributes = True

class UserInfo(BaseModel):
  sub: str
  preferred_username: str
  email: Optional[str] = None

# Database dependency
def get_db():
  db = SessionLocal()
  try:
    yield db
  finally:
    db.close()

# Create tables
Base.metadata.create_all(bind=engine)

# Google OAuth functions
async def get_google_public_keys():
  """Fetch Google's public keys for JWT verification"""
  async with aiohttp.ClientSession() as session:
    async with session.get("https://www.googleapis.com/oauth2/v3/certs") as response:
      if response.status == 200:
        return await response.json()
      else:
        raise HTTPException(
          status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
          detail="Unable to fetch Google public keys"
        )

async def verify_google_token_async(token: str) -> dict:
  """Verify Google OAuth token using aiohttp"""
  try:
    logger.debug(f"Starting token verification for token: {token[:50]}...")
    
    # Get Google's public keys
    logger.debug("Fetching Google public keys...")
    jwks = await get_google_public_keys()
    logger.debug(f"Retrieved {len(jwks.get('keys', []))} public keys")
    
    # Decode JWT header to get key ID
    unverified_header = jwt.get_unverified_header(token)
    key_id = unverified_header.get("kid")
    logger.debug(f"Token key ID: {key_id}")
    
    if not key_id:
      raise ValueError("Token missing key ID")
    
    # Find the matching public key
    signing_key = None
    for key_data in jwks.get("keys", []):
      if key_data.get("kid") == key_id:
        logger.debug(f"Found matching key for ID: {key_id}")
        # Create RSA key from JWK
        from cryptography.hazmat.primitives.asymmetric import rsa
        from cryptography.hazmat.primitives import serialization
        import base64
        
        # Decode the public key components
        n = base64.urlsafe_b64decode(key_data["n"] + "===")
        e = base64.urlsafe_b64decode(key_data["e"] + "===")
        
        # Convert to RSA public key
        public_numbers = rsa.RSAPublicNumbers(
          int.from_bytes(e, 'big'),
          int.from_bytes(n, 'big')
        )
        public_key = public_numbers.public_key()
        
        # Convert to PEM format for PyJWT
        signing_key = public_key.public_bytes(
          encoding=serialization.Encoding.PEM,
          format=serialization.PublicFormat.SubjectPublicKeyInfo
        )
        break
    
    if not signing_key:
      logger.error(f"Public key not found for key ID: {key_id}")
      raise ValueError("Public key not found for token")
    
    logger.debug(f"Verifying JWT with audience: {GOOGLE_CLIENT_ID}")
    # Verify the JWT
    payload = jwt.decode(
      token,
      signing_key,
      algorithms=["RS256"],
      audience=GOOGLE_CLIENT_ID,
      issuer="https://accounts.google.com",
      options={"verify_exp": True, "verify_aud": True, "verify_iss": True}
    )
    
    logger.debug(f"Token verification successful. Payload: {payload}")
    return payload
    
  except Exception as e:
    logger.error(f"Token verification failed: {str(e)}")
    raise ValueError(f"Token verification failed: {str(e)}")

async def verify_google_token(credentials: HTTPAuthorizationCredentials = Depends(http_bearer)) -> dict:
  """Verify Google OAuth token"""
  token = credentials.credentials
  logger.debug(f"Received token for verification: {token[:50]}...")
  
  try:
    # Use our async verification
    idinfo = await verify_google_token_async(token)
    
    # Verify the issuer (extra check)
    if idinfo['iss'] not in ['accounts.google.com', 'https://accounts.google.com']:
      logger.error(f"Invalid issuer: {idinfo['iss']}")
      raise HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Invalid token issuer"
      )
    
    logger.debug("Token verification completed successfully")
    return idinfo
  except ValueError as e:
    logger.error(f"OAuth verification error: {str(e)}")
    raise HTTPException(
      status_code=status.HTTP_401_UNAUTHORIZED,
      detail=f"Invalid token: {str(e)}",
      headers={"WWW-Authenticate": "Bearer"},
    )

async def get_current_user(token_payload: dict = Depends(verify_google_token)) -> UserInfo:
  """Get current user from token payload"""
  return UserInfo(
    sub=token_payload.get("sub") or "",
    preferred_username=token_payload.get("email") or "",
    email=token_payload.get("email")
  )

# API Endpoints
@app.get("/")
async def root():
  """Root endpoint"""
  return {
    "message": "Stock Watchlist API with Google OAuth",
    "version": "1.0.0",
    "authentication": "Google OAuth 2.0",
    "endpoints": {
      "me": "/me",
      "stocks": "/stocks"
    },
    "instructions": "Include your Google OAuth token in the Authorization header as 'Bearer <token>'"
  }

@app.get("/me", response_model=UserInfo)
async def read_users_me(current_user: UserInfo = Depends(get_current_user)):
  """Get current user information"""
  return current_user

@app.get("/stocks", response_model=List[StockResponse])
async def get_stocks(
  current_user: UserInfo = Depends(get_current_user),
  db: Session = Depends(get_db)
):
  """Get all stocks for the current user"""
  stocks = db.query(Stock).filter(Stock.user_id == current_user.sub).all()
  return stocks

@app.post("/stocks", response_model=StockResponse, status_code=status.HTTP_201_CREATED)
async def create_stock(
  stock: StockCreate,
  current_user: UserInfo = Depends(get_current_user),
  db: Session = Depends(get_db)
):
  """Create a new stock in the watchlist"""
  # Check if stock already exists for this user
  existing_stock = db.query(Stock).filter(
    Stock.symbol == stock.symbol.upper(),
    Stock.user_id == current_user.sub
  ).first()
  
  if existing_stock:
    raise HTTPException(
      status_code=status.HTTP_400_BAD_REQUEST,
      detail=f"Stock {stock.symbol} already exists in your watchlist"
    )
  
  db_stock = Stock(
    symbol=stock.symbol.upper(),
    name=stock.name,
    price=stock.price,
    user_id=current_user.sub
  )
  db.add(db_stock)
  db.commit()
  db.refresh(db_stock)
  return db_stock

@app.get("/stocks/{stock_id}", response_model=StockResponse)
async def get_stock(
  stock_id: int,
  current_user: UserInfo = Depends(get_current_user),
  db: Session = Depends(get_db)
):
  """Get a specific stock by ID"""
  stock = db.query(Stock).filter(
    Stock.id == stock_id,
    Stock.user_id == current_user.sub
  ).first()
  
  if not stock:
    raise HTTPException(
      status_code=status.HTTP_404_NOT_FOUND,
      detail="Stock not found"
    )
  return stock

@app.put("/stocks/{stock_id}", response_model=StockResponse)
async def update_stock(
  stock_id: int,
  stock_update: StockUpdate,
  current_user: UserInfo = Depends(get_current_user),
  db: Session = Depends(get_db)
):
  """Update a stock in the watchlist"""
  stock = db.query(Stock).filter(
    Stock.id == stock_id,
    Stock.user_id == current_user.sub
  ).first()
  
  if not stock:
    raise HTTPException(
      status_code=status.HTTP_404_NOT_FOUND,
      detail="Stock not found"
    )
  
  if stock_update.name is not None:
    stock.name = stock_update.name
  if stock_update.price is not None:
    stock.price = stock_update.price
  
  stock.updated_at = datetime.utcnow()
  db.commit()
  db.refresh(stock)
  return stock

@app.delete("/stocks/{stock_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_stock(
  stock_id: int,
  current_user: UserInfo = Depends(get_current_user),
  db: Session = Depends(get_db)
):
  """Delete a stock from the watchlist"""
  stock = db.query(Stock).filter(
    Stock.id == stock_id,
    Stock.user_id == current_user.sub
  ).first()
  
  if not stock:
    raise HTTPException(
      status_code=status.HTTP_404_NOT_FOUND,
      detail="Stock not found"
    )
  
  db.delete(stock)
  db.commit()
  return None

@app.get("/health")
async def health_check():
  """Health check endpoint"""
  return {"status": "healthy"}
