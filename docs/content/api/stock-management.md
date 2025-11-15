---
title: "Stock Management"
description: "CRUD operations for stock watchlist management"
weight: 3
---

## GET /stocks

Get all stocks for the authenticated user.

### Request

```http
GET /stocks
Authorization: Bearer YOUR_GOOGLE_ID_TOKEN
```

### Response

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

### Example

```bash
curl -X GET "http://localhost:8000/stocks" \
  -H "Authorization: Bearer YOUR_GOOGLE_ID_TOKEN"
```

---

## POST /stocks

Create a new stock in the watchlist.

### Request

```http
POST /stocks
Authorization: Bearer YOUR_GOOGLE_ID_TOKEN
Content-Type: application/json
```

### Request Body

```json
{
  "symbol": "AAPL",
  "name": "Apple Inc.",
  "price": 175.50
}
```

### Fields

- `symbol` (string, required): Stock ticker symbol
- `name` (string, required): Company name
- `price` (float, required): Current stock price

### Response

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

### Example

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

---

## GET /stocks/{id}

Get a specific stock by ID.

### Request

```http
GET /stocks/{id}
Authorization: Bearer YOUR_GOOGLE_ID_TOKEN
```

### Path Parameters

- `id` (integer): Stock ID

### Response

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

### Example

```bash
curl -X GET "http://localhost:8000/stocks/1" \
  -H "Authorization: Bearer YOUR_GOOGLE_ID_TOKEN"
```

### Error Responses

#### 404 Not Found

```json
{
  "detail": "Stock not found"
}
```

---

## PUT /stocks/{id}

Update a stock's information.

### Request

```http
PUT /stocks/{id}
Authorization: Bearer YOUR_GOOGLE_ID_TOKEN
Content-Type: application/json
```

### Path Parameters

- `id` (integer): Stock ID to update

### Request Body

You can update any combination of these fields:

```json
{
  "symbol": "AAPL",
  "name": "Apple Inc. (Updated)",
  "price": 180.25
}
```

### Response

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

### Example

```bash
curl -X PUT "http://localhost:8000/stocks/1" \
  -H "Authorization: Bearer YOUR_GOOGLE_ID_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Apple Inc. (Updated)",
    "price": 180.25
  }'
```

---

## DELETE /stocks/{id}

Delete a stock from the watchlist.

### Request

```http
DELETE /stocks/{id}
Authorization: Bearer YOUR_GOOGLE_ID_TOKEN
```

### Path Parameters

- `id` (integer): Stock ID to delete

### Response

```json
{
  "message": "Stock deleted successfully"
}
```

### Example

```bash
curl -X DELETE "http://localhost:8000/stocks/1" \
  -H "Authorization: Bearer YOUR_GOOGLE_ID_TOKEN"
```

### Error Responses

#### 404 Not Found

```json
{
  "detail": "Stock not found"
}
```

## Data Models

### Stock Object

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

### Field Descriptions

- `id`: Unique identifier for the stock record
- `symbol`: Stock ticker symbol (e.g., "AAPL", "GOOGL")
- `name`: Full company name
- `price`: Current stock price (decimal)
- `user_id`: Google user ID (ensures data isolation)
- `created_at`: Timestamp when stock was added
- `updated_at`: Timestamp when stock was last modified