---
title: "Testing the API"
description: "Complete guide to testing all API endpoints with examples"
weight: 4
---

## Prerequisites for Testing

Before testing the API endpoints, ensure you have:

1. ✅ **API running**: Docker containers started with `./setup.sh` or `docker-compose up -d`
2. ✅ **Google OAuth token**: See [OAuth Setup](../oauth-setup/) for getting tokens
3. ✅ **Testing tool**: curl, Postman, Bruno, or similar HTTP client

## Quick Test Script

The project includes an automated test script:

```bash
# Test public endpoints only
./test-api.sh

# Test all endpoints with authentication
./test-api.sh YOUR_GOOGLE_OAUTH_TOKEN
```

## Manual Testing Guide

### 1. Health Check (No Authentication)

Test that the API is running:

```bash
curl -X GET "http://localhost:8000/health"
```

**Expected Response:**
```json
{
  "status": "healthy"
}
```

### 2. Root Endpoint (No Authentication)

```bash
curl -X GET "http://localhost:8000/"
```

**Expected Response:**
```json
{
  "message": "Stock Watchlist API"
}
```

### 3. Get Current User Info (Authentication Required)

Test your OAuth token:

```bash
curl -X GET "http://localhost:8000/me" \
  -H "Authorization: Bearer YOUR_GOOGLE_ID_TOKEN"
```

**Expected Response:**
```json
{
  "sub": "114357175967131345226",
  "preferred_username": "your.email@gmail.com", 
  "email": "your.email@gmail.com"
}
```

**If this fails:**
- ❌ Check you're using **ID token** (not access token)
- ❌ Verify token hasn't expired (Google tokens expire in 1 hour)
- ❌ Confirm `GOOGLE_CLIENT_ID` in `.env` matches Google Cloud Console

### 4. Create a New Stock (Authentication Required)

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

**Expected Response:**
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

### 5. Get All User's Stocks (Authentication Required)

```bash
curl -X GET "http://localhost:8000/stocks" \
  -H "Authorization: Bearer YOUR_GOOGLE_ID_TOKEN"
```

**Expected Response:**
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

### 6. Get Specific Stock by ID (Authentication Required)

```bash
curl -X GET "http://localhost:8000/stocks/1" \
  -H "Authorization: Bearer YOUR_GOOGLE_ID_TOKEN"
```

**Expected Response:**
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

### 7. Update a Stock (Authentication Required)

Update the price and/or name:

```bash
curl -X PUT "http://localhost:8000/stocks/1" \
  -H "Authorization: Bearer YOUR_GOOGLE_ID_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Apple Inc. (Updated)",
    "price": 180.25
  }'
```

**Expected Response:**
```json
{
  "id": 1,
  "symbol": "AAPL",
  "name": "Apple Inc. (Updated)",
  "price": 180.25,
  "user_id": "114357175967131345226", 
  "created_at": "2025-11-15T19:30:00",
  "updated_at": "2025-11-15T19:35:00"
}
```

### 8. Delete a Stock (Authentication Required)

```bash
curl -X DELETE "http://localhost:8000/stocks/1" \
  -H "Authorization: Bearer YOUR_GOOGLE_ID_TOKEN"
```

**Expected Response:**
```json
{
  "message": "Stock deleted successfully"
}
```

## Complete Testing Workflow

Here's a complete test sequence to validate all functionality:

```bash
# Replace with your actual Google OAuth ID token
export TOKEN="YOUR_GOOGLE_ID_TOKEN"

# 1. Check API health
echo "1. Testing health endpoint..."
curl -s http://localhost:8000/health | jq

# 2. Test authentication
echo -e "\n2. Testing authentication..."
curl -s -H "Authorization: Bearer $TOKEN" http://localhost:8000/me | jq

# 3. Create first stock
echo -e "\n3. Creating Apple stock..."
curl -s -X POST http://localhost:8000/stocks \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"symbol":"AAPL","name":"Apple Inc.","price":175.50}' | jq

# 4. Create second stock
echo -e "\n4. Creating Microsoft stock..."
curl -s -X POST http://localhost:8000/stocks \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"symbol":"MSFT","name":"Microsoft Corp.","price":420.75}' | jq

# 5. Get all stocks
echo -e "\n5. Getting all stocks..."
curl -s -H "Authorization: Bearer $TOKEN" http://localhost:8000/stocks | jq

# 6. Get specific stock
echo -e "\n6. Getting Apple stock by ID..."
curl -s -H "Authorization: Bearer $TOKEN" http://localhost:8000/stocks/1 | jq

# 7. Update stock
echo -e "\n7. Updating Apple stock price..."
curl -s -X PUT http://localhost:8000/stocks/1 \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"price":180.25}' | jq

# 8. Delete stock
echo -e "\n8. Deleting Microsoft stock..."
curl -s -X DELETE http://localhost:8000/stocks/2 \
  -H "Authorization: Bearer $TOKEN" | jq

# 9. Verify deletion
echo -e "\n9. Verifying remaining stocks..."
curl -s -H "Authorization: Bearer $TOKEN" http://localhost:8000/stocks | jq
```

## Testing with Swagger UI

For interactive testing, use the built-in Swagger UI:

1. **Open Swagger UI**: http://localhost:8000/docs
2. **Click "Authorize"** button in the top right
3. **Enter token**: `Bearer YOUR_GOOGLE_ID_TOKEN` (include "Bearer " prefix)
4. **Click "Authorize"**
5. **Test endpoints**: Click any endpoint → "Try it out" → fill parameters → "Execute"

## Testing with Postman/Bruno

### Setting up OAuth 2.0 in Postman/Bruno:

1. **Auth Type**: OAuth 2.0
2. **Grant Type**: Authorization Code
3. **Auth URL**: `https://accounts.google.com/o/oauth2/v2/auth`
4. **Access Token URL**: `https://oauth2.googleapis.com/token`
5. **Client ID**: Your Google Client ID
6. **Client Secret**: Your Google Client Secret  
7. **Scope**: `openid email profile`
8. **Use ID Token**: Make sure to use the **ID token** (not access token)

### Creating Test Collection:

Create requests for each endpoint:
- Set `Authorization` header to `Bearer {{id_token}}`
- Use `{{base_url}}` variable set to `http://localhost:8000`
- Create environment variables for common test data

## Error Testing

### Test Invalid Authentication

```bash
# Missing token
curl -X GET http://localhost:8000/me

# Invalid token 
curl -X GET http://localhost:8000/me \
  -H "Authorization: Bearer invalid_token"

# Expired token
curl -X GET http://localhost:8000/me \
  -H "Authorization: Bearer EXPIRED_TOKEN"
```

**Expected Response for all:**
```json
{
  "detail": "Invalid token"
}
```

### Test Invalid Stock Data

```bash
# Missing required fields
curl -X POST http://localhost:8000/stocks \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"symbol":"AAPL"}'

# Invalid price type
curl -X POST http://localhost:8000/stocks \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"symbol":"AAPL","name":"Apple","price":"not_a_number"}'
```

### Test Access Control

```bash
# Try to access another user's stock (use different Google accounts)
curl -X GET http://localhost:8000/stocks/999 \
  -H "Authorization: Bearer $TOKEN"
```

**Expected Response:**
```json
{
  "detail": "Stock not found"
}
```

## Performance Testing

For basic load testing:

```bash
# Install apache bench (if not already installed)
# macOS: brew install httpd
# Ubuntu: apt-get install apache2-utils

# Test health endpoint (no auth)
ab -n 1000 -c 10 http://localhost:8000/health

# Test authenticated endpoint (replace with your token)
ab -n 100 -c 5 -H "Authorization: Bearer YOUR_TOKEN" http://localhost:8000/me
```

## Troubleshooting Test Issues

### "Connection refused"
- ✅ Check containers are running: `docker-compose ps`
- ✅ Verify ports: FastAPI should be on 8000, MySQL on 3306
- ✅ Check logs: `docker-compose logs fastapi`

### "Invalid token" errors
- ✅ Use **ID token** (not access token) from Google
- ✅ Include `Bearer ` prefix in Authorization header
- ✅ Token expires after 1 hour - get a fresh one
- ✅ Verify `GOOGLE_CLIENT_ID` in `.env` matches Google Cloud Console

### "Stock not found" errors
- ✅ Stocks are isolated by user - you can only see your own stocks
- ✅ Check the stock ID exists: `GET /stocks` first
- ✅ Use correct stock ID in URL path

### Database connection issues
- ✅ Check MySQL container: `docker-compose logs mysql`
- ✅ Verify database credentials in `.env`
- ✅ Wait for MySQL to fully start (can take 30-60 seconds)

## Test Data Management

### Reset test data:

```bash
# Stop containers and remove database volume
docker-compose down -v

# Restart with fresh database
docker-compose up -d

# Wait for startup
sleep 30
```

### Backup test data:

```bash
# Export current database
docker-compose exec mysql mysqldump -u stockuser -p stockwatchlist > backup.sql

# Import later
docker-compose exec -T mysql mysql -u stockuser -p stockwatchlist < backup.sql
```

## API Endpoint Summary

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| `GET` | `/` | ❌ | API info |
| `GET` | `/health` | ❌ | Health check |
| `GET` | `/me` | ✅ | Current user info |
| `GET` | `/stocks` | ✅ | Get user's stocks |
| `POST` | `/stocks` | ✅ | Create stock |
| `GET` | `/stocks/{id}` | ✅ | Get specific stock |
| `PUT` | `/stocks/{id}` | ✅ | Update stock |
| `DELETE` | `/stocks/{id}` | ✅ | Delete stock |

## Next Steps

After testing the API:

1. **[Explore API Documentation]({{ "/api/" | relURL }})** - Detailed endpoint documentation
2. **[Development Guide](../architecture/)** - Architecture and development info  
3. **[OAuth Setup](../oauth-setup/)** - Detailed OAuth configuration

Need help? Check the comprehensive [troubleshooting guide](../troubleshooting/) for common issues and solutions.