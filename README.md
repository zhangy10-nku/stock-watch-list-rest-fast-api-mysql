# Stock Watch List REST API

A multi-containerized stock watchlist REST API built with FastAPI, MySQL, and Google OAuth authentication.

---

# 🎓 **CS640: IMPORTANT - PLEASE READ** 🎓

## **📌 Instead of using Laravel, I'm using FastAPI Python back-end REST framework to write this app. I'm using MySQL on a separate docker container.**

## **📖 Please review the rest of this README for:**
- **🏗️ Architecture diagram**
- **🐳 Docker setup details**
- **⚙️ Setup instructions**
- **🧪 Sample curl commands for testing**

---

## Table of Contents
- [Architecture](#architecture)
- [Features](#features)
- [Technologies Used](#technologies-used)
- [Quick Start](#quick-start)
- [Testing the API](#testing-the-api)
- [API Endpoints](#api-endpoints)
- [API Documentation](#api-documentation)
- [Development & Debugging](#development)
- [OAuth Setup (Detailed)](#oauth-setup-detailed)
- [Troubleshooting](#troubleshooting)

## Architecture

This application consists of two Docker containers:
- **MySQL 8.0**: Database for storing stock watchlist data with persistent volumes
- **FastAPI (Python 3.13)**: Modern Python REST API with Google OAuth authentication, running with uvicorn

```
┌─────────────────────┐    ┌─────────────────────────┐
│   Client/Browser    │    │  Docker Network         │
│                     │    │                         │
│  • curl/Postman     │    │  ┌─────────────────────┐│
│  • Web Browser      │───▶│  │   FastAPI:8000      ││
│  • OAuth Token      │8000│  │   Python 3.13       ││
│                     │    │  │   + debugpy:5678    ││
└─────────────────────┘    │  └──────────┬──────────┘│
                           │             │           │
                           │  ┌──────────▼──────────┐│
                           │  │   MySQL:3306        ││
                           │  │   Database Storage  ││
                           │  └─────────────────────┘│
                           └─────────────────────────┘
```

## Features

- 🔐 **Google OAuth 2.0 Authentication**: Secure token-based authentication
- 📊 **Stock Watchlist CRUD**: Complete Create, Read, Update, Delete operations
- 🐳 **Multi-Container Docker**: MySQL and FastAPI in separate containers
- 🔄 **RESTful API Design**: Standard REST endpoints with proper HTTP methods
- 🗄️ **MySQL Persistence**: Data stored in MySQL with proper indexes
- 👤 **User Isolation**: Each user's stocks are isolated by their Google account
- 🐍 **Python 3.13**: Latest Python with performance improvements
- 🚀 **Fast & Async**: Async OAuth verification with aiohttp
- 🔧 **VS Code Debugging**: Full debugging support with breakpoints

## Technologies Used

- **FastAPI**: Modern, fast Python web framework for building APIs
- **Python 3.13**: Latest Python with significant performance improvements
- **SQLAlchemy**: SQL toolkit and ORM for database operations
- **PyMySQL**: Pure Python MySQL database adapter
- **Google OAuth 2.0**: Secure authentication and identity management
- **Docker & Docker Compose**: Multi-container orchestration
- **MySQL 8.0**: Enterprise-grade relational database
- **uv**: Fast Python package installer and resolver
- **debugpy**: Python debugging for VS Code
- **aiohttp**: Async HTTP client for non-blocking OAuth verification

## Quick Start

### Prerequisites

- Docker and Docker Compose installed
- A Google account  
- Git

### 🚀 One-Command Setup (Recommended)

This project includes professional deployment scripts that automate the entire setup process, from prerequisite checking to OAuth configuration to API testing.

```bash
git clone <repository-url>
cd stock-watch-list-rest-fast-api-mysql
./setup.sh
```

**That's it!** The setup script will:
- ✅ Check all prerequisites (Docker, ports, etc.)
- ✅ Prompt for your Google OAuth credentials
- ✅ Create `.env` file automatically
- ✅ Build and start containers
- ✅ Wait for services to be ready
- ✅ Test API endpoints
- ✅ Show you exactly how to use the API

### Manual Setup (Alternative)

If you prefer manual setup:

### 1. Clone the repository

```bash
git clone <repository-url>
cd stock-watch-list-rest-fast-api-mysql
```

### 2. Set up environment variables

Create a `.env` file in the project root:

```bash
# MySQL Configuration
MYSQL_ROOT_PASSWORD=rootpassword
MYSQL_DATABASE=stockwatchlist
MYSQL_USER=stockuser
MYSQL_PASSWORD=stockpass

# Google OAuth Configuration (get these from Google Cloud Console)
GOOGLE_CLIENT_ID=your-client-id.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=your-client-secret

# FastAPI Configuration
DATABASE_URL=mysql+pymysql://stockuser:stockpass@mysql:3306/stockwatchlist

# Debug Mode (optional - set to true for VS Code debugging)
DEBUG=false
```

**📝 Note**: To get your Google OAuth credentials, see the [OAuth Setup section](#oauth-setup-detailed) below.

### 3. Start the application

```bash
docker-compose up -d --build
```

This will:
- Build the FastAPI container with Python 3.13
- Start MySQL container  
- Initialize the database with the schema
- Start FastAPI on `http://localhost:8000`

### 4. Verify containers are running

```bash
docker-compose ps
```

You should see both containers running:
- `stock-watchlist-mysql` on port 3306
- `stock-watchlist-api` on port 8000

## 🛠️ Deployment Scripts

This project includes professional deployment scripts for easy management:

### Setup Script (`setup.sh`)
**One command to set up everything:**
```bash
./setup.sh                 # Standard setup
./setup.sh --rebuild       # Force rebuild containers
./setup.sh --clean         # Clean setup (removes old data)
```

**Features:**
- ✅ Checks Docker installation and prerequisites
- ✅ Verifies port availability (8000, 3306)
- ✅ Interactive Google OAuth credential setup
- ✅ Creates `.env` file automatically
- ✅ Builds and starts containers with health checks
- ✅ Tests API endpoints
- ✅ Provides helpful next steps and commands

### Deployment Script (`deploy.sh`)
**Deploy to different environments:**
```bash
./deploy.sh local          # Local development (default)
./deploy.sh staging        # Staging environment  
./deploy.sh production     # Production deployment
./deploy.sh status         # Check deployment status
```

### Cleanup Script (`cleanup.sh`)
**Clean up resources:**
```bash
./cleanup.sh --containers  # Stop and remove containers only
./cleanup.sh --volumes     # Also remove volumes (deletes data)
./cleanup.sh --images      # Also remove Docker images
./cleanup.sh --all         # Complete reset to fresh state
```

### 5. Get a test token

To test the API, you need a Google OAuth token. Quick options:

**Option 1: OAuth Playground (Fastest)**
1. Go to [Google OAuth 2.0 Playground](https://developers.google.com/oauthplayground/)
2. Click the gear icon ⚙️, check "Use your own OAuth credentials"
3. Enter your Client ID and Client Secret
4. Select "Google OAuth2 API v2" → check `userinfo.email` and `userinfo.profile`
5. Authorize and get your **ID token** (not access token!)

**Option 2: Use the detailed [OAuth Setup](#oauth-setup-detailed) section below**

## Testing the API

### Get current user info

```bash
curl -X GET "http://localhost:8000/me" \
  -H "Authorization: Bearer YOUR_GOOGLE_ID_TOKEN"
```

**Response:**
```json
{
  "sub": "114357175967131345226",
  "preferred_username": "your.email@gmail.com",
  "email": "your.email@gmail.com"
}
```

### Create a stock

```bash
curl -X POST "http://localhost:8000/stocks" \
  -H "Authorization: Bearer YOUR_GOOGLE_ID_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "symbol": "AAPL",
    "name": "Apple Inc.",
    "price": 175.50
  }'
```

**Response:**
```json
{
  "id": 1,
  "symbol": "AAPL",
  "name": "Apple Inc.",
  "price": 175.5,
  "user_id": "114357175967131345226",
  "created_at": "2025-11-15T19:30:00",
  "updated_at": "2025-11-15T19:30:00"
}
```

### Get all stocks for the authenticated user

```bash
curl -X GET "http://localhost:8000/stocks" \
  -H "Authorization: Bearer YOUR_GOOGLE_ID_TOKEN"
```

**Response:**
```json
[
  {
    "id": 1,
    "symbol": "AAPL",
    "name": "Apple Inc.",
    "price": 175.5,
    "user_id": "114357175967131345226",
    "created_at": "2025-11-15T19:30:00",
    "updated_at": "2025-11-15T19:30:00"
  }
]
```

### Get a specific stock by ID

```bash
curl -X GET "http://localhost:8000/stocks/1" \
  -H "Authorization: Bearer YOUR_GOOGLE_ID_TOKEN"
```

### Update a stock

```bash
curl -X PUT "http://localhost:8000/stocks/1" \
  -H "Authorization: Bearer YOUR_GOOGLE_ID_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Apple Inc. (Updated)",
    "price": 180.25
  }'
```

### Delete a stock

```bash
curl -X DELETE "http://localhost:8000/stocks/1" \
  -H "Authorization: Bearer YOUR_GOOGLE_ID_TOKEN"
```

**Response:**
```json
{
  "message": "Stock deleted successfully"
}
```

## API Endpoints

| Method | Endpoint | Description | Auth Required | Example Response |
|--------|----------|-------------|---------------|------------------|
| GET | `/` | Root endpoint with API info | No | `{"message": "Stock Watchlist API"}` |
| GET | `/health` | Health check | No | `{"status": "healthy"}` |
| GET | `/me` | Get current authenticated user info | Yes | User object with email |
| GET | `/stocks` | Get all stocks for authenticated user | Yes | Array of stock objects |
| POST | `/stocks` | Create a new stock | Yes | Created stock object |
| GET | `/stocks/{id}` | Get specific stock by ID | Yes | Stock object |
| PUT | `/stocks/{id}` | Update a stock (name/price) | Yes | Updated stock object |
| DELETE | `/stocks/{id}` | Delete a stock | Yes | Success message |

## API Documentation

Once the application is running, you can access interactive API documentation:

- **Swagger UI**: http://localhost:8000/docs
  - Interactive API explorer
  - Try out endpoints directly in the browser
  - View request/response schemas

- **ReDoc**: http://localhost:8000/redoc
  - Clean, professional API documentation
  - Better for reading and understanding the API

**Note**: To test authenticated endpoints in Swagger UI, click "Authorize" and add `Bearer YOUR_TOKEN` in the value field.

## Project Structure

```
.
├── app/
│   └── main.py                 # FastAPI application with OAuth and CRUD
├── .vscode/
│   ├── launch.json             # VS Code debug configurations
│   └── settings.json           # VS Code settings
├── docker-compose.yml          # Multi-container orchestration
├── Dockerfile                  # FastAPI container with Python 3.13
├── pyproject.toml              # uv dependency configuration
├── requirements.txt            # Python dependencies
├── init.sql                    # MySQL database initialization
├── .env                        # Environment variables (not in git)
├── .gitignore                  # Git ignore rules
└── README.md                   # This file
```

## Development

### Step 1: Create a Google Cloud Project

1. Go to the [Google Cloud Console](https://console.cloud.google.com/)
2. Click "Select a Project" → "New Project"
3. Enter a project name (e.g., "Stock Watchlist API")
4. Click "Create"

### Step 2: Enable Google+ API (Optional but recommended)

1. In the Google Cloud Console, go to "APIs & Services" → "Library"
2. Search for "Google+ API"
3. Click on it and press "Enable"

### Step 3: Configure OAuth Consent Screen

1. Go to "APIs & Services" → "OAuth consent screen"
2. Select "External" (unless you have a Google Workspace)
3. Click "Create"
4. Fill in the required fields:
   - **App name**: Stock Watchlist API
   - **User support email**: Your email
   - **Developer contact information**: Your email
5. Click "Save and Continue"
6. **Scopes**: Click "Add or Remove Scopes"
   - Add `openid`
   - Add `email`
   - Add `profile`
7. Click "Save and Continue"
8. **Test users**: Add your Google email address (required for External apps in testing)
9. Click "Save and Continue"

### Step 4: Create OAuth 2.0 Credentials

1. Go to "APIs & Services" → "Credentials"
2. Click "Create Credentials" → "OAuth client ID"
3. Select "Web application"
4. Fill in the fields:
   - **Name**: Stock Watchlist API Client
   - **Authorized JavaScript origins**: `http://localhost:8000` (add more URLs as needed)
   - **Authorized redirect URIs**: Add these based on how you'll get tokens:
     - For OAuth Playground: `https://developers.google.com/oauthplayground`
     - For Bruno: `https://oauth.pstmn.io/v1/callback`
     - For Postman: `https://oauth.pstmn.io/v1/callback`
     - (You don't need a callback for direct token validation in this API)
5. Click "Create"
6. **IMPORTANT**: Copy your **Client ID** and **Client Secret**
   - Client ID looks like: `123456789-abcdefg.apps.googleusercontent.com`
   - Client Secret looks like: `GOCSPX-abcdefghijklmnop`

### Do You Need an API Key?

**No, you don't need an API key!** You only need:
- ✅ **OAuth Client ID** (from Step 4)
- ✅ **OAuth Client Secret** (from Step 4)

The Client ID and Client Secret are used to verify tokens from clients. API keys are different and not needed for OAuth authentication.

## How OAuth Works in This Setup

This API uses **token validation** rather than **OAuth flow handling**:

1. **You get tokens** from Google (via OAuth Playground, Bruno, etc.)
2. **You send tokens** to this API in the `Authorization` header
3. **API validates tokens** directly with Google

**This means:**
- ❌ The API doesn't redirect users to Google
- ❌ The API doesn't handle OAuth callbacks
- ✅ The API only validates ID tokens
- ✅ Callback URLs are for the tool you use to GET tokens (OAuth Playground, Bruno)

**Callback URLs to configure in Google Cloud Console:**
- `https://developers.google.com/oauthplayground` - For OAuth Playground
- `https://oauth.pstmn.io/v1/callback` - For Bruno/Postman

## Quick Start

### 1. Clone the repository

```bash
git clone <repository-url>
cd stock-watch-list-rest-fast-api-mysql
```

### 2. Create environment file

```bash
cp .env.example .env
```

Edit `.env` and add your Google OAuth credentials:

```bash
GOOGLE_CLIENT_ID=your-client-id.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=your-client-secret
```

### 3. Start the application

```bash
docker-compose up -d --build
```

This will start both containers:
- MySQL: `localhost:3306`
- FastAPI: `localhost:8000`

## Getting a Google OAuth Token

To use the API, you need to get a Google OAuth token. Here are the methods:

### Method 1: OAuth 2.0 Playground (Easiest for Testing)

1. Go to [Google OAuth 2.0 Playground](https://developers.google.com/oauthplayground/)
2. Click the gear icon (⚙️) in the top right
3. Check "Use your own OAuth credentials"
4. Enter your **Client ID** and **Client Secret**
5. In the left panel, select "Google OAuth2 API v2" → check `userinfo.email` and `userinfo.profile`
6. Click "Authorize APIs"
7. Sign in with your Google account
8. Click "Exchange authorization code for tokens"
9. Copy the **ID token** (not the access token) - this is what you'll use in the `Authorization` header

### Method 2: Using Bruno/Postman

Create a new request with OAuth 2.0 authentication:
- Auth Type: OAuth 2.0
- Grant Type: Authorization Code
- Auth URL: `https://accounts.google.com/o/oauth2/v2/auth`
- Access Token URL: `https://oauth2.googleapis.com/token`
- Client ID: Your Client ID
- Client Secret: Your Client Secret
- Scope: `openid email profile`

After authentication, use the **ID token** in your requests.

### Method 3: Using Google Sign-In Button (Production)

For production apps, implement Google Sign-In on your frontend and pass the ID token to your API.

## Testing the API

### Get current user info

```bash
curl -X GET "http://localhost:8000/me" \
  -H "Authorization: Bearer YOUR_GOOGLE_ID_TOKEN"
```

Response:
```json
{
  "sub": "1234567890",
  "preferred_username": "yourname@gmail.com",
  "email": "yourname@gmail.com"
}
```

### Create a stock

```bash
curl -X POST "http://localhost:8000/stocks" \
  -H "Authorization: Bearer YOUR_GOOGLE_ID_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "symbol": "AAPL",
    "name": "Apple Inc.",
    "price": 175.50
  }'
```

### Get all stocks

```bash
curl -X GET "http://localhost:8000/stocks" \
  -H "Authorization: Bearer YOUR_GOOGLE_ID_TOKEN"
```

### Update a stock

```bash
curl -X PUT "http://localhost:8000/stocks/1" \
  -H "Authorization: Bearer YOUR_GOOGLE_ID_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "price": 180.25
  }'
```

### Delete a stock

```bash
curl -X DELETE "http://localhost:8000/stocks/1" \
  -H "Authorization: Bearer YOUR_GOOGLE_ID_TOKEN"
```

## API Documentation

Once the application is running, you can access:
- **Interactive API docs (Swagger UI)**: http://localhost:8000/docs
- **Alternative API docs (ReDoc)**: http://localhost:8000/redoc

**Note**: To use the Swagger UI with Google OAuth, you'll need to manually add the `Authorization: Bearer <token>` header in the "Authorize" section.

## API Endpoints

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/` | Root endpoint with API info | No |
| GET | `/me` | Get current user info | Yes |
| GET | `/stocks` | Get all stocks for user | Yes |
| POST | `/stocks` | Create a new stock | Yes |
| GET | `/stocks/{id}` | Get stock by ID | Yes |
| PUT | `/stocks/{id}` | Update a stock | Yes |
| DELETE | `/stocks/{id}` | Delete a stock | Yes |
| GET | `/health` | Health check | No |

## Project Structure

```
.
├── app/
│   └── main.py              # FastAPI application with Google OAuth
├── docker-compose.yml       # Docker Compose configuration (MySQL + FastAPI)
├── Dockerfile              # FastAPI container image
├── pyproject.toml          # uv dependency configuration
├── requirements.txt        # Python dependencies
├── init.sql               # MySQL initialization script
├── .env.example           # Environment variables template
├── .gitignore            # Git ignore rules
└── README.md             # This file
```

## Environment Variables

See `.env.example` for all available environment variables:

- **MySQL**: Database credentials and configuration
- **Google OAuth**: Client ID and Client Secret from Google Cloud Console
- **FastAPI**: Database connection string

## Managing the Application

### 🚀 Using Deployment Scripts (Recommended)

```bash
# Quick setup or rebuild
./setup.sh --rebuild

# Check status
./deploy.sh status  

# Clean restart
./cleanup.sh --containers && ./setup.sh

# Complete reset (removes all data)
./cleanup.sh --all && ./setup.sh
```

### 🔧 Manual Docker Commands

### View logs

```bash
# All services
docker-compose logs -f

# Specific service  
docker-compose logs -f fastapi
docker-compose logs -f mysql
```

### Rebuild after code changes

```bash
docker-compose up -d --build
```

### Stop the application

```bash
docker-compose down
```

### Stop and remove all data (including database)

```bash
docker-compose down -v
```

### Restart a specific service

```bash
docker-compose restart fastapi
```

## Development

### Debugging with VS Code

This project includes a complete debugging setup that allows you to set breakpoints and debug your FastAPI application running inside Docker containers.

#### 🔧 **Debug Setup Features**
- ✅ **Remote debugging**: Debug code running inside Docker containers
- ✅ **Real container environment**: Debug the exact same environment as production
- ✅ **Hot reload**: Code changes automatically reload with `--reload`
- ✅ **VS Code integration**: Full debugging support with breakpoints, variable inspection, call stack
- ✅ **Path mapping**: Breakpoints work correctly between local files and container

#### 🚀 **How to Debug**

**1. Enable Debug Mode**
Set `DEBUG=true` in your `.env` file:
```bash
DEBUG=true
```

**2. Start Containers with Debug**
```bash
docker-compose down
docker-compose up -d --build
```

When `DEBUG=true`, the FastAPI container will:
- Start `debugpy` on port 5678
- Wait for VS Code to connect
- Enable `--reload` for hot reloading

**3. Set Breakpoints in VS Code**
- Open `app/main.py` in VS Code
- Click in the gutter (left margin) next to line numbers to set breakpoints
- Good places to set breakpoints:
  - Inside `verify_google_token_async()` function
  - Inside `verify_google_token()` function  
  - At the start of any API endpoint like `/me`, `/stocks`, etc.

**4. Start Debug Session**
- Open **Run and Debug** panel (Cmd+Shift+D / Ctrl+Shift+D)
- Select **"Debug FastAPI in Docker"** from the dropdown
- Click the play button ▶️
- VS Code will connect to the container debugger at `localhost:5678`

**5. Test Your API**
Make requests to trigger your breakpoints:
```bash
curl http://localhost:8000/me -H "authorization: Bearer YOUR_TOKEN"
```

**6. Debug Features Available**
- **Step Over** (F10) - Execute current line
- **Step Into** (F11) - Go into function calls
- **Step Out** (Shift+F11) - Exit current function
- **Continue** (F5) - Continue to next breakpoint
- **Variable inspection** - Hover over variables to see values
- **Watch expressions** - Add variables to watch panel
- **Call stack** - See the execution path
- **Conditional breakpoints** - Right-click breakpoint for conditions

#### 🔧 **Debug Configuration**

The project includes three debug configurations in `.vscode/launch.json`:

1. **"Debug FastAPI in Docker"** *(Recommended)*
   - Connects to debugpy running in Docker container
   - Uses path mapping between local `/app` and container `/app`
   - Port: 5678

2. **"Debug FastAPI with Uvicorn"** *(Local Development)*
   - Runs FastAPI locally (outside Docker)
   - Connects to local MySQL container
   - Useful for faster iteration

3. **"Debug FastAPI (Local DB)"** *(Fully Local)*
   - Runs FastAPI locally with local MySQL
   - Requires local MySQL setup

#### 🔄 **Switch Between Modes**

**Debug Mode** (in `.env`):
```bash
DEBUG=true
```
- Starts debugpy server on port 5678
- Waits for VS Code debugger to connect
- Enables `--reload` for hot reloading
- Container ports: 8000 (FastAPI) + 5678 (Debug)

**Production Mode** (in `.env`):
```bash
DEBUG=false
```
- Runs FastAPI normally with uvicorn
- No debug server
- Container port: 8000 (FastAPI only)

#### 🐳 **Container Debug Architecture**

```
┌─────────────────────┐    ┌─────────────────────────┐
│   VS Code (Local)   │    │  Docker Container       │
│                     │    │                         │
│  • Set breakpoints  │    │  ┌─────────────────────┐ │
│  • Debug controls   │◄───┤  │     debugpy         │ │
│  • Variable watch   │5678│  │   (Port 5678)       │ │
│                     │    │  └─────────────────────┘ │
└─────────────────────┘    │  ┌─────────────────────┐ │
                           │  │   FastAPI + uvicorn │ │
┌─────────────────────┐    │  │   (Port 8000)       │ │
│   API Client        │    │  └─────────────────────┘ │
│  (curl/browser)     │◄───┤                         │
│                     │8000│  Path Mapping:          │
└─────────────────────┘    │  /local/app ↔ /app      │
                           └─────────────────────────┘
```

#### 🔍 **Debugging Example**

Set a breakpoint in the OAuth verification function:

1. Open `app/main.py`
2. Set breakpoint on line inside `verify_google_token_async()`
3. Start "Debug FastAPI in Docker"
4. Make API call:
   ```bash
   curl http://localhost:8000/me -H "authorization: Bearer YOUR_TOKEN"
   ```
5. VS Code will pause at your breakpoint
6. Inspect variables like `token`, `jwks`, `payload`
7. Step through the OAuth verification process

#### 💡 **Debugging Tips**

- **Container Logs**: `docker-compose logs -f fastapi` to see debugpy status
- **Port Check**: Ensure port 5678 is not used by other applications
- **Path Mapping**: Breakpoints work because local `./app` maps to container `/app`
- **Hot Reload**: Change code and it automatically reloads (with `DEBUG=true`)
- **Environment Variables**: Debug configuration uses container environment

#### 🛠 **Troubleshooting Debug Setup**

**"Debugger not connecting"**
- Check `DEBUG=true` in `.env`
- Verify containers are running: `docker-compose ps`
- Check debugpy is waiting: `docker-compose logs fastapi`
- Ensure port 5678 is available locally

**"Breakpoints not hitting"**
- Verify path mapping in `launch.json`
- Check file paths match between local and container
- Ensure you're using "Debug FastAPI in Docker" configuration

**"Code changes not reloading"**
- Confirm `DEBUG=true` enables `--reload`
- Check volume mapping in `docker-compose.yml`: `./app:/app`
- **Restart containers if needed: `docker-compose restart fastapi`

---

## OAuth Setup (Detailed)

This section provides detailed instructions for setting up Google OAuth credentials. **You only need to do this once** to get your `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET`.

### How OAuth Works in This App

This API uses **token validation** rather than **OAuth flow handling**:

1. **You get tokens** from Google (via OAuth Playground, Bruno, Postman, etc.)
2. **You send tokens** to this API in the `Authorization: Bearer` header
3. **API validates tokens** directly with Google's public keys

**This means:**
- ❌ The API doesn't redirect users to Google
- ❌ The API doesn't handle OAuth callbacks
- ✅ The API only validates ID tokens sent by clients
- ✅ Callback URLs are configured for the tool you use to GET tokens

### Step 1: Create a Google Cloud Project

1. Go to the [Google Cloud Console](https://console.cloud.google.com/)
2. Click "Select a Project" → "New Project"
3. Enter a project name (e.g., "Stock Watchlist API")
4. Click "Create"

### Step 2: Configure OAuth Consent Screen

1. Go to "APIs & Services" → "OAuth consent screen"
2. Select "External" (unless you have a Google Workspace)
3. Click "Create"
4. Fill in the required fields:
   - **App name**: Stock Watchlist API
   - **User support email**: Your email
   - **Developer contact information**: Your email
5. Click "Save and Continue"
6. **Scopes**: Click "Add or Remove Scopes"
   - Add `openid`
   - Add `email`
   - Add `profile`
7. Click "Save and Continue"
8. **Test users**: Add your Google email address (required for External apps in testing)
9. Click "Save and Continue"

### Step 3: Create OAuth 2.0 Credentials

1. Go to "APIs & Services" → "Credentials"
2. Click "Create Credentials" → "OAuth client ID"
3. Select "Web application"
4. Fill in the fields:
   - **Name**: Stock Watchlist API Client
   - **Authorized JavaScript origins**: `http://localhost:8000`
   - **Authorized redirect URIs**: 
     - `https://developers.google.com/oauthplayground` (for OAuth Playground)
     - `https://oauth.pstmn.io/v1/callback` (for Postman/Bruno)
5. Click "Create"
6. **IMPORTANT**: Copy your **Client ID** and **Client Secret**
   - Client ID looks like: `123456789-abcdefg.apps.googleusercontent.com`
   - Client Secret looks like: `GOCSPX-abcdefghijklmnop`
7. Add these to your `.env` file

### Getting Tokens for Testing

#### Method 1: OAuth 2.0 Playground (Easiest)

1. Go to [Google OAuth 2.0 Playground](https://developers.google.com/oauthplayground/)
2. Click the gear icon (⚙️) in the top right
3. Check "Use your own OAuth credentials"
4. Enter your **Client ID** and **Client Secret**
5. In the left panel, select "Google OAuth2 API v2"
6. Check `userinfo.email` and `userinfo.profile`
7. Click "Authorize APIs"
8. Sign in with your Google account
9. Click "Exchange authorization code for tokens"
10. Copy the **ID token** (not the access token!)
11. Use this in your `Authorization: Bearer` header

**Note**: Tokens expire after 1 hour. Just repeat steps 9-10 to get a fresh token.

#### Method 2: Using Bruno/Postman

Create a new request with OAuth 2.0 authentication:
- **Auth Type**: OAuth 2.0
- **Grant Type**: Authorization Code
- **Auth URL**: `https://accounts.google.com/o/oauth2/v2/auth`
- **Access Token URL**: `https://oauth2.googleapis.com/token`
- **Client ID**: Your Client ID
- **Client Secret**: Your Client Secret
- **Scope**: `openid email profile`

After authentication, use the **ID token** (not access token) in your requests.

#### Method 3: Production Apps

For production applications, implement Google Sign-In on your frontend:
- Use Google Sign-In JavaScript library
- Get the ID token from the sign-in response
- Send it to this API in the `Authorization: Bearer` header

### Do You Need an API Key?

**No!** You only need:
- ✅ **OAuth Client ID** (from Step 3)
- ✅ **OAuth Client Secret** (from Step 3)

API keys are different and not needed for OAuth authentication.

### OAuth Consent Screen "Unverified App" Warning

When testing, you may see "This app isn't verified":
- This is normal for apps in testing mode
- Click "Advanced" → "Go to [app name] (unsafe)" to proceed
- For production, you need to verify your app with Google

### OAuth Pricing

- **Free tier**: Up to 50,000 requests per day
- **Cost**: Free for basic OAuth (email, profile, openid scopes)
- **No charges** for authentication under reasonable use
- Only charged for specific Google API calls (Drive, Calendar, etc.)

For more details, see [Google Cloud Pricing](https://cloud.google.com/pricing)

---

## Troubleshooting

### "Invalid token" errors
- Make sure you're using the **ID token**, not the access token from Google
- Verify your `GOOGLE_CLIENT_ID` matches the one in Google Cloud Console
- Check that the token hasn't expired (Google ID tokens expire after 1 hour)

### Database connection issues
- Check MySQL is healthy: `docker-compose ps`
- Verify credentials in `.env` file

### "Connection refused" or "ECONNRESET"
- Ensure containers are running: `docker-compose ps`
- Check if debugpy is waiting: `docker-compose logs fastapi`
- If `DEBUG=true`, either attach VS Code debugger or set `DEBUG=false`
- Restart containers: `docker-compose restart fastapi`

### Port conflicts
- If port 8000 or 3306 is already in use:
  ```bash
  # Check what's using the port
  lsof -i :8000
  lsof -i :3306
  
  # Stop other services or change ports in docker-compose.yml
  ```

### Container won't start
- Check logs: `docker-compose logs fastapi`
- Verify environment variables in `.env`
- Try rebuilding: `docker-compose down && docker-compose up -d --build`

### Permission issues with volumes
```bash
# Remove volumes and recreate
docker-compose down -v
docker-compose up -d
```

---

## Environment Variables Reference

Create a `.env` file with these variables:

```bash
# MySQL Configuration
MYSQL_ROOT_PASSWORD=rootpassword      # Root password for MySQL
MYSQL_DATABASE=stockwatchlist         # Database name
MYSQL_USER=stockuser                  # MySQL user for the app
MYSQL_PASSWORD=stockpass              # MySQL user password

# Google OAuth Configuration
GOOGLE_CLIENT_ID=your-client-id.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=your-client-secret

# FastAPI Configuration
DATABASE_URL=mysql+pymysql://stockuser:stockpass@mysql:3306/stockwatchlist

# Debug Mode (optional)
DEBUG=false                           # Set to 'true' for VS Code debugging
```

---

## 🎯 For Your Professor 

**One-command deployment for easy grading:**

```bash
git clone <repository-url>
cd stock-watch-list-rest-fast-api-mysql
./setup.sh
```

The setup script will:
1. ✅ Check all prerequisites automatically
2. ✅ Guide you through OAuth setup (just need Google Client ID/Secret)
3. ✅ Build and start everything with Docker
4. ✅ Test all endpoints 
5. ✅ Provide sample curl commands for testing

**Testing the API:**
```bash
# Test public endpoints
./test-api.sh

# Test with authentication (after getting Google OAuth token)
./test-api.sh YOUR_GOOGLE_OAUTH_TOKEN
```

**Complete cleanup if needed:**
```bash
./cleanup.sh --all
```

---

## Script Reference

| Script | Purpose | Usage |
|--------|---------|-------|
| `setup.sh` | One-command setup and deployment | `./setup.sh [--rebuild\|--clean]` |
| `deploy.sh` | Multi-environment deployment | `./deploy.sh [local\|staging\|production]` |
| `cleanup.sh` | Clean up resources | `./cleanup.sh [--containers\|--volumes\|--all]` |
| `test-api.sh` | Test API endpoints | `./test-api.sh [OAUTH_TOKEN]` |
| `docs/hugo-dev.sh` | Hugo documentation development | `./docs/hugo-dev.sh [serve\|build\|clean]` |

## 📚 Documentation

This project includes comprehensive Hugo-based documentation that automatically deploys to GitHub Pages:

- **📖 Live Documentation**: Available at GitHub Pages (auto-deployed)
- **🚀 Local Development**: Use `./docs/hugo-dev.sh serve` to preview locally
- **🐳 Docker-Based**: No local Hugo/Node.js installation required
- **🔄 Auto-Deploy**: Pushes to `main` automatically update documentation

### Hugo Development

```bash
# Start development server with auto-reload
./docs/hugo-dev.sh serve

# Build production site
./docs/hugo-dev.sh build  

# View all commands
./docs/hugo-dev.sh help
```

The documentation site will be available at:
- **Local**: http://localhost:1313/stock-watch-list-rest-fast-api-mysql/
- **Production**: https://zhangy10-nku.github.io/stock-watch-list-rest-fast-api-mysql/

---

## License

MIT License
