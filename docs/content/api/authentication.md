---
title: "Authentication"
description: "User authentication and profile endpoints"
weight: 2
---

## GET /me

Get information about the currently authenticated user.

### Request

```http
GET /me
Authorization: Bearer YOUR_GOOGLE_ID_TOKEN
```

### Response

```json
{
  "sub": "114357175967131345226",
  "preferred_username": "your.email@gmail.com", 
  "email": "your.email@gmail.com"
}
```

### Fields

- `sub`: Google user ID (unique identifier)
- `preferred_username`: User's email address
- `email`: User's email address

### Example

```bash
curl -X GET "http://localhost:8000/me" \
  -H "Authorization: Bearer YOUR_GOOGLE_ID_TOKEN"
```

### Error Responses

#### 401 Unauthorized

```json
{
  "detail": "Invalid authentication credentials"
}
```

Occurs when:
- No Authorization header is provided
- Invalid or expired token
- Token format is incorrect