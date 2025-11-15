---
title: "Documentation"
description: "Complete documentation for the Stock Watchlist API"
weight: 1
---

A multi-containerized stock watchlist REST API built with **FastAPI**, **MySQL**, and **Google OAuth** authentication.

## Overview

This documentation covers everything you need to know about the Stock Watchlist API:

### 🚀 Getting Started
Quick setup with our one-command deployment script - [Quick Start Guide](quick-start/)

### 📚 API Reference  
Complete API endpoint documentation - [API Reference](/api/)

### 🏗️ Architecture
System design and component overview - [Architecture Guide](architecture/)

## Features

- 🔐 **Google OAuth 2.0 Authentication**: Secure token-based authentication
- 📊 **Stock Watchlist CRUD**: Complete Create, Read, Update, Delete operations
- 🐳 **Multi-Container Docker**: MySQL and FastAPI in separate containers
- 🔄 **RESTful API Design**: Standard REST endpoints with proper HTTP methods
- 🗄️ **MySQL Persistence**: Data stored in MySQL with proper indexes
- 👤 **User Isolation**: Each user's stocks are isolated by their Google account
- 🐍 **Python 3.13**: Latest Python with performance improvements
- 🚀 **Fast & Async**: Async OAuth verification with aiohttp
- 🔧 **VS Code Debugging**: Full debugging support with breakpoints

## Technologies Used

- **FastAPI**: Modern, fast Python web framework for building APIs
- **Python 3.13**: Latest Python with significant performance improvements
- **SQLAlchemy**: SQL toolkit and ORM for database operations
- **PyMySQL**: Pure Python MySQL database adapter
- **Google OAuth 2.0**: Secure authentication and identity management
- **Docker & Docker Compose**: Multi-container orchestration
- **MySQL 8.0**: Enterprise-grade relational database
- **uv**: Fast Python package installer and resolver
- **debugpy**: Python debugging for VS Code
- **aiohttp**: Async HTTP client for non-blocking OAuth verification