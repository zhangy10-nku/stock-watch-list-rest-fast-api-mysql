---
title: "API Reference"
description: "Complete API documentation for all endpoints"
weight: 30
---

Complete reference for all API endpoints in the Stock Watchlist API.

## Base URL

```
http://localhost:8000
```

## Authentication

All protected endpoints require a Google OAuth 2.0 ID token in the Authorization header:

```http
Authorization: Bearer YOUR_GOOGLE_ID_TOKEN
```

## API Endpoints Overview

| Method | Endpoint | Description | Auth Required | 
|--------|----------|-------------|---------------|
| GET | `/` | Root endpoint with API info | No |
| GET | `/health` | Health check | No |
| GET | `/me` | Get current authenticated user info | Yes |
| GET | `/stocks` | Get all stocks for authenticated user | Yes |
| POST | `/stocks` | Create a new stock | Yes |
| GET | `/stocks/{id}` | Get specific stock by ID | Yes |
| PUT | `/stocks/{id}` | Update a stock (name/price) | Yes |
| DELETE | `/stocks/{id}` | Delete a stock | Yes |