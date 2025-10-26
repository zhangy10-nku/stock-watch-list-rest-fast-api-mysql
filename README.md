# Stock Watch List REST API

A multi-containerized stock watchlist REST API built with FastAPI, MySQL, and Google OAuth authentication.

## Architecture

This application consists of two Docker containers:
- **MySQL**: Database for storing stock watchlist data
- **FastAPI**: Python REST API for managing stock watchlist items with Google OAuth authentication

## Features

- 🔐 Google OAuth 2.0 authentication
- 📊 Stock watchlist CRUD operations
- 🐳 Multi-container Docker setup
- 🔄 RESTful API design
- 🗄️ MySQL database persistence
- 👤 User-specific data isolation (based on Google account)

## Prerequisites

- Docker and Docker Compose
- A Google account
- Git

## Google OAuth Setup

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

## Stopping the Application

```bash
docker-compose down
```

To remove volumes (delete all data):

```bash
docker-compose down -v
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
- Restart containers if needed: `docker-compose restart fastapi`

To view logs:

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f fastapi
docker-compose logs -f mysql
```

To rebuild after code changes:

```bash
docker-compose up -d --build
```

## Troubleshooting

### "Invalid token" errors
- Make sure you're using the **ID token**, not the access token from Google
- Verify your `GOOGLE_CLIENT_ID` matches the one in Google Cloud Console
- Check that the token hasn't expired (Google ID tokens expire after 1 hour)

### Database connection issues
- Check MySQL is healthy: `docker-compose ps`
- Verify credentials in `.env` file

### OAuth consent screen shows "unverified app"
- This is normal for apps in testing mode
- Click "Advanced" → "Go to [app name] (unsafe)" to proceed
- For production, you need to verify your app with Google

## Google OAuth Pricing

- **Free tier**: Up to 50,000 requests per day
- **Cost**: Free for basic OAuth (email, profile, openid scopes)
- **No charges** for authentication under reasonable use
- Only charged for specific Google API calls (Drive, Calendar, etc.)

For more details, see [Google Cloud Pricing](https://cloud.google.com/pricing)

## Technologies Used

- **FastAPI**: Modern Python web framework
- **SQLAlchemy**: SQL toolkit and ORM
- **PyMySQL**: MySQL database adapter
- **Google OAuth 2.0**: Authentication and identity management
- **Docker & Docker Compose**: Containerization
- **MySQL**: Relational database
- **uv**: Fast Python package installer and resolver

## License

MIT License
