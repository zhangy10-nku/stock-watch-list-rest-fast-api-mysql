---
title: "Architecture"
description: "System architecture and component overview"
weight: 2
---

## System Overview

This application consists of two Docker containers orchestrated with Docker Compose:

- **MySQL 8.0**: Database for storing stock watchlist data with persistent volumes
- **FastAPI (Python 3.13)**: Modern Python REST API with Google OAuth authentication, running with uvicorn

## Architecture Diagram

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

## Component Details

### FastAPI Application

- **Framework**: FastAPI with Python 3.13
- **Server**: Uvicorn ASGI server
- **Authentication**: Google OAuth 2.0 token validation
- **ORM**: SQLAlchemy with async support
- **Database Driver**: PyMySQL
- **Debug Support**: debugpy for VS Code integration

### MySQL Database

- **Version**: MySQL 8.0
- **Storage**: Persistent volumes for data durability
- **Schema**: Single table design with user isolation
- **Indexes**: Optimized queries for user-specific data

### Docker Network

- **Type**: Bridge network
- **Communication**: Internal container-to-container communication
- **Ports**: Exposed ports for external access (8000, 3306)
- **Volumes**: Persistent data storage

## Data Flow

1. **Client Request**: HTTP request with OAuth token
2. **Token Validation**: Async verification with Google's public keys
3. **Database Query**: User-isolated data operations
4. **Response**: JSON response with requested data

## Security Model

- **Authentication**: Google OAuth 2.0 ID tokens
- **Authorization**: User-based data isolation
- **Data Validation**: Pydantic models for request/response validation
- **SQL Injection Prevention**: SQLAlchemy ORM parameterized queries

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