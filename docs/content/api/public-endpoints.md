---
title: "Public Endpoints"
description: "Endpoints that don't require authentication"
weight: 1
---

## GET /

Root endpoint with API information.

### Request

```http
GET /
```

### Response

```json
{
  "message": "Stock Watchlist API"
}
```

## GET /health

Health check endpoint for monitoring.

### Request

```http
GET /health
```

### Response

```json
{
  "status": "healthy"
}
```

### Example

```bash
curl -X GET "http://localhost:8000/health"
```