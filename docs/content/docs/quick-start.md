---
title: "Quick Start"
description: "Get your Stock Watchlist API up and running in minutes"
weight: 1
---

## Prerequisites

- Docker and Docker Compose installed
- A Google account  
- Git

## 🚀 One-Command Setup (Recommended)

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

## Manual Setup (Alternative)

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

## Quick Test

Once running, test the API:

```bash
# Test health endpoint (no authentication required)
curl http://localhost:8000/health

# Test with authentication (replace with your Google OAuth token)
curl -H "Authorization: Bearer YOUR_GOOGLE_ID_TOKEN" http://localhost:8000/me
```

**Need a test token?** See the [OAuth Setup guide](../oauth-setup/) for getting Google OAuth credentials and tokens.

## Next Steps

1. [Set up Google OAuth credentials](../oauth-setup/)
2. [Test the API endpoints](../testing/)
3. [View API documentation](../../api/)
4. [Troubleshooting guide](../troubleshooting/) - If you run into issues