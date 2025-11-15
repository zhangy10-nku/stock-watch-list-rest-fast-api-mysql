# Stock Watchlist API Documentation

This directory contains the Hugo-based documentation site for the Stock Watchlist API.

## 🚀 Quick Start

### Local Development

```bash
# Start development server (requires Docker)
./hugo-dev.sh serve

# Build production site
./hugo-dev.sh build
```

### Directory Structure

```
docs/
├── hugo-dev.sh           # Development scripts (Docker-based)
├── hugo.toml             # Hugo configuration
├── content/              # Markdown content
│   ├── _index.html      # Homepage
│   ├── docs/            # Documentation pages
│   └── api/             # API reference
└── layouts/             # Custom HTML templates
    └── _default/        # Default layouts
```

## 🌐 Deployment

- **Auto-Deploy**: Changes pushed to `main` branch automatically deploy via GitHub Actions
- **GitHub Pages**: https://zhangy10-nku.github.io/stock-watch-list-rest-fast-api-mysql/
- **Local Preview**: http://localhost:1313/stock-watch-list-rest-fast-api-mysql/

## 📝 Content Organization

- **Homepage** (`content/_index.html`): Landing page with overview
- **Documentation** (`content/docs/`): Setup guides, architecture, OAuth setup
- **API Reference** (`content/api/`): Complete endpoint documentation

## 🔧 Technical Details

- **Hugo Version**: 0.111.3 (via Docker)
- **Theme**: Custom layouts (no external theme dependencies)
- **Styling**: Bootstrap 5 + Font Awesome via CDN
- **Deployment**: GitHub Actions + GitHub Pages
- **No Node.js Required**: Everything runs in Docker containers

## 🐳 Why Docker?

- **No Local Installation**: No need to install Hugo, Node.js, or theme dependencies
- **Consistent Environment**: Same Hugo version everywhere (local, CI, production)
- **Simple Setup**: Just Docker required
- **GitHub Actions Compatible**: Uses same Docker image for deployment