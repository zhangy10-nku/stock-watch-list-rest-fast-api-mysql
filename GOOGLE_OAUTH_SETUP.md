# Google OAuth Setup Guide - Quick Reference

## What You Need

1. **Google Cloud Console Account** (free)
2. **OAuth 2.0 Client Credentials** (not an API key!)
   - Client ID
   - Client Secret

## How This Works

This API **validates tokens** rather than handling OAuth flows:
- You get tokens from Google OAuth Playground or Bruno
- You send the ID token to the API
- The API validates it with Google

**Callback URLs:** These are for the tool you use to GET tokens (OAuth Playground, Bruno), NOT for this API.

## Do I Need an API Key?

**NO!** You don't need an API key. Google OAuth uses:
- ✅ OAuth Client ID
- ✅ OAuth Client Secret

API keys are for different Google services (Maps, YouTube, etc.) and are NOT used for OAuth authentication.

## Quick Setup Steps

### 1. Create Google Cloud Project
- Go to: https://console.cloud.google.com/
- Create new project: "Stock Watchlist API"

### 2. Configure OAuth Consent Screen
- Go to: APIs & Services → OAuth consent screen
- Choose: External
- Fill in app name and emails
- Add scopes: `openid`, `email`, `profile`
- Add test users: Your Gmail address

### 3. Create OAuth Credentials
- Go to: APIs & Services → Credentials
- Create: OAuth client ID → Web application
- Add authorized redirect URIs:
  - `https://developers.google.com/oauthplayground` (for OAuth Playground)
  - `https://oauth.pstmn.io/v1/callback` (for Bruno/Postman)
- **Save your Client ID and Client Secret!**

### 4. Add to .env file
```bash
GOOGLE_CLIENT_ID=123456-abcd.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=GOCSPX-abcdefghijklmnop
```

## Getting Test Tokens

### Method 1: OAuth Playground (Recommended)
1. Go to: https://developers.google.com/oauthplayground/
2. Click gear icon → "Use your own OAuth credentials"
3. Enter your Client ID and Secret
4. Select: Google OAuth2 API v2 → userinfo.email, userinfo.profile
5. Authorize → Exchange for tokens
6. Copy the **ID token** (not access token!)

### Method 2: Bruno/Postman
- Auth Type: OAuth 2.0
- Grant Type: Authorization Code
- Auth URL: `https://accounts.google.com/o/oauth2/v2/auth`
- Token URL: `https://oauth2.googleapis.com/token`
- Client ID: Your Client ID
- Client Secret: Your Client Secret
- Scope: `openid email profile`

Use the **ID token** from the response!

## Testing Your API

```bash
# Get your user info
curl -X GET "http://localhost:8000/me" \
  -H "Authorization: Bearer YOUR_ID_TOKEN"

# Create a stock
curl -X POST "http://localhost:8000/stocks" \
  -H "Authorization: Bearer YOUR_ID_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"symbol": "AAPL", "name": "Apple Inc.", "price": 175.50}'
```

## Pricing

- **Free**: Up to 50,000 requests/day
- **Cost**: $0 for basic OAuth
- Only charged for specific Google API usage (Drive, Calendar, etc.)
- Perfect for POC apps!

## Common Issues

### "Invalid token issuer"
- Make sure you're using the **ID token**, not the access token
- ID tokens start with `eyJ...` and contain user info

### "Token expired"
- Google ID tokens expire after 1 hour
- Get a new token from OAuth Playground

### "unverified app" warning
- Normal for testing mode apps
- Click "Advanced" → "Go to app (unsafe)"
- For production, submit app for verification

## Resources

- Google OAuth Playground: https://developers.google.com/oauthplayground/
- Google Cloud Console: https://console.cloud.google.com/
- Google OAuth Docs: https://developers.google.com/identity/protocols/oauth2
