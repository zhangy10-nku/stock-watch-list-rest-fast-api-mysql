#!/bin/bash

# Hugo Documentation Development Scripts
# Uses Docker to avoid local Hugo/Node.js installation requirements

set -e

DOCS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HUGO_IMAGE="klakegg/hugo:0.111.3"

# Change to docs directory
cd "$DOCS_DIR"

case "${1:-help}" in
    "serve"|"dev")
        echo "🚀 Starting Hugo development server with Docker..."
        echo "📝 Site will be available at: http://localhost:1313/stock-watch-list-rest-fast-api-mysql/"
        echo "🔄 Auto-reload enabled - edit files and see changes instantly"
        echo "⏹️  Press Ctrl+C to stop the server"
        echo ""
        docker run --rm -it \
            -v "$(pwd):/src" \
            -p 1313:1313 \
            "$HUGO_IMAGE" \
            server --bind 0.0.0.0 --buildDrafts
        ;;
    
    "build")
        echo "🏗️  Building Hugo site with Docker..."
        docker run --rm \
            -v "$(pwd):/src" \
            "$HUGO_IMAGE" \
            --buildDrafts --minify
        echo "✅ Site built successfully in ./public/"
        ;;
    
    "clean")
        echo "🧹 Cleaning generated files..."
        rm -rf public/ resources/ .hugo_build.lock
        echo "✅ Cleaned up generated files"
        ;;
    
    "test")
        echo "🧪 Testing Hugo configuration..."
        docker run --rm \
            -v "$(pwd):/src" \
            "$HUGO_IMAGE" \
            --buildDrafts --printPathWarnings --printUnusedTemplates
        echo "✅ Configuration test completed"
        ;;
    
    "help"|*)
        echo "📚 Hugo Documentation Development Scripts"
        echo ""
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "  serve, dev    Start development server (auto-reload)"
        echo "  build         Build production site"
        echo "  clean         Remove generated files"
        echo "  test          Test Hugo configuration"
        echo "  help          Show this help message"
        echo ""
        echo "📝 The site will be available at:"
        echo "   http://localhost:1313/stock-watch-list-rest-fast-api-mysql/"
        echo ""
        echo "🐳 Using Hugo Docker image: $HUGO_IMAGE"
        ;;
esac