---
title: "OAuth Setup"
description: "Complete guide to setting up Google OAuth credentials"
weight: 3
---

This section provides detailed instructions for setting up Google OAuth credentials. **You only need to do this once** to get your `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET`.

## How OAuth Works in This App

This API uses **token validation** rather than **OAuth flow handling**:

1. **You get tokens** from Google (via OAuth Playground, Bruno, Postman, etc.)
2. **You send tokens** to this API in the `Authorization: Bearer` header
3. **API validates tokens** directly with Google's public keys

**This means:**
- ❌ The API doesn't redirect users to Google
- ❌ The API doesn't handle OAuth callbacks
- ✅ The API only validates ID tokens sent by clients
- ✅ Callback URLs are configured for the tool you use to GET tokens

## Step 1: Create a Google Cloud Project

1. Go to the [Google Cloud Console](https://console.cloud.google.com/)
2. Click "Select a Project" → "New Project"
3. Enter a project name (e.g., "Stock Watchlist API")
4. Click "Create"

## Step 2: Configure OAuth Consent Screen

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

## Step 3: Create OAuth 2.0 Credentials

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

## Getting Tokens for Testing

### Method 1: OAuth 2.0 Playground (Easiest)

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

> **Note**: Tokens expire after 1 hour. Just repeat steps 9-10 to get a fresh token.

### Method 2: Using Bruno/Postman

Create a new request with OAuth 2.0 authentication:
- **Auth Type**: OAuth 2.0
- **Grant Type**: Authorization Code
- **Auth URL**: `https://accounts.google.com/o/oauth2/v2/auth`
- **Access Token URL**: `https://oauth2.googleapis.com/token`
- **Client ID**: Your Client ID
- **Client Secret**: Your Client Secret
- **Scope**: `openid email profile`

After authentication, use the **ID token** (not access token) in your requests.

### Method 3: Production Apps

For production applications, implement Google Sign-In on your frontend:
- Use Google Sign-In JavaScript library
- Get the ID token from the sign-in response
- Send it to this API in the `Authorization: Bearer` header

## Do You Need an API Key?

**No!** You only need:
- ✅ **OAuth Client ID** (from Step 3)
- ✅ **OAuth Client Secret** (from Step 3)

API keys are different and not needed for OAuth authentication.

## OAuth Consent Screen "Unverified App" Warning

When testing, you may see "This app isn't verified":
- This is normal for apps in testing mode
- Click "Advanced" → "Go to [app name] (unsafe)" to proceed
- For production, you need to verify your app with Google

## OAuth Pricing

- **Free tier**: Up to 50,000 requests per day
- **Cost**: Free for basic OAuth (email, profile, openid scopes)
- **No charges** for authentication under reasonable use
- Only charged for specific Google API calls (Drive, Calendar, etc.)

For more details, see [Google Cloud Pricing](https://cloud.google.com/pricing)