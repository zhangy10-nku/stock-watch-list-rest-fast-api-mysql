#!/bin/bash

# Stock Watchlist API - One-Command Setup Script
# Usage: ./setup.sh [--rebuild] [--clean]
# Author: CS640 Project

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Configuration
API_PORT=8000
DB_PORT=3306
PROJECT_NAME="Stock Watchlist API"

# Print colored output
print_status() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_header() {
    echo -e "${BOLD}${BLUE}"
    echo "==========================================="
    echo "  🚀 $PROJECT_NAME Setup"
    echo "==========================================="
    echo -e "${NC}"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if port is available
port_available() {
    ! lsof -i :$1 >/dev/null 2>&1
}

# Wait for service to be ready
wait_for_service() {
    local url=$1
    local service_name=$2
    local max_attempts=30
    local attempt=1
    
    print_status "Waiting for $service_name to be ready..."
    
    while [ $attempt -le $max_attempts ]; do
        if curl -s $url > /dev/null 2>&1; then
            print_success "$service_name is ready!"
            return 0
        fi
        echo -n "."
        sleep 2
        attempt=$((attempt + 1))
    done
    
    print_error "$service_name failed to start within $(($max_attempts * 2)) seconds"
    return 1
}

# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check Docker
    if ! command_exists docker; then
        print_error "Docker is not installed. Please install Docker first:"
        echo "  macOS: brew install --cask docker"
        echo "  Linux: https://docs.docker.com/engine/install/"
        exit 1
    fi
    
    # Check Docker Compose
    if ! command_exists docker-compose && ! docker compose version >/dev/null 2>&1; then
        print_error "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi
    
    # Check if Docker daemon is running
    if ! docker info >/dev/null 2>&1; then
        print_error "Docker daemon is not running. Please start Docker first."
        exit 1
    fi
    
    print_success "Prerequisites check passed!"
}

# Check ports
check_ports() {
    print_status "Checking port availability..."
    
    if ! port_available $API_PORT; then
        print_error "Port $API_PORT is already in use. Please stop the service using this port:"
        lsof -i :$API_PORT
        exit 1
    fi
    
    if ! port_available $DB_PORT; then
        print_warning "Port $DB_PORT is in use. This might be another MySQL instance."
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    print_success "Ports are available!"
}

# Setup environment file
setup_environment() {
    print_status "Setting up environment variables..."
    
    if [ -f ".env" ] && [ "$1" != "--force" ]; then
        print_success ".env file already exists, skipping creation."
        return 0
    fi
    
    echo "📝 Creating .env file..."
    echo "🔐 You'll need Google OAuth credentials for authentication."
    echo "   Get them from: https://console.cloud.google.com/"
    echo ""
    
    # Get OAuth credentials
    read -p "Enter your Google Client ID: " GOOGLE_CLIENT_ID
    read -p "Enter your Google Client Secret: " GOOGLE_CLIENT_SECRET
    
    # Create .env file
    cat > .env << EOF
# MySQL Configuration
MYSQL_ROOT_PASSWORD=rootpassword
MYSQL_DATABASE=stockwatchlist
MYSQL_USER=stockuser
MYSQL_PASSWORD=stockpass

# Google OAuth Configuration
GOOGLE_CLIENT_ID=$GOOGLE_CLIENT_ID
GOOGLE_CLIENT_SECRET=$GOOGLE_CLIENT_SECRET

# FastAPI Configuration
DATABASE_URL=mysql+pymysql://stockuser:stockpass@mysql:3306/stockwatchlist

# Debug Mode (set to true for VS Code debugging)
DEBUG=false
EOF
    
    print_success ".env file created successfully!"
}

# Build and start containers
start_containers() {
    print_status "Building and starting containers..."
    
    # Determine rebuild flag
    local build_flag=""
    if [ "$1" = "--rebuild" ]; then
        build_flag="--build --no-cache"
        print_status "Force rebuilding containers..."
    elif [ "$1" = "--clean" ]; then
        print_status "Cleaning up existing containers..."
        docker-compose down -v 2>/dev/null || true
        build_flag="--build --no-cache"
    fi
    
    # Build and start
    echo "🐳 Building Docker containers..."
    if ! docker-compose up -d $build_flag; then
        print_error "Failed to start containers"
        exit 1
    fi
    
    print_success "Containers started successfully!"
}

# Wait for services
wait_for_services() {
    print_status "Waiting for services to be ready..."
    
    # Wait for MySQL
    print_status "Waiting for MySQL database..."
    local attempt=1
    while [ $attempt -le 30 ]; do
        if docker-compose exec -T mysql mysqladmin ping -h localhost --silent 2>/dev/null; then
            print_success "MySQL is ready!"
            break
        fi
        echo -n "."
        sleep 2
        attempt=$((attempt + 1))
    done
    
    if [ $attempt -gt 30 ]; then
        print_error "MySQL failed to start"
        return 1
    fi
    
    # Wait for FastAPI
    wait_for_service "http://localhost:$API_PORT/health" "FastAPI"
}

# Test API endpoints
test_api() {
    print_status "Testing API endpoints..."
    
    # Test health endpoint
    if ! curl -s "http://localhost:$API_PORT/health" | grep -q "healthy"; then
        print_error "Health check failed"
        return 1
    fi
    
    # Test root endpoint
    if ! curl -s "http://localhost:$API_PORT/" >/dev/null; then
        print_error "Root endpoint test failed"
        return 1
    fi
    
    print_success "API endpoints are working!"
}

# Display success information
show_success_info() {
    echo ""
    echo -e "${BOLD}${GREEN}🎉 Setup Complete! 🎉${NC}"
    echo ""
    echo -e "${BOLD}📍 Your API is running at:${NC}"
    echo "   • API: http://localhost:$API_PORT"
    echo "   • API Docs: http://localhost:$API_PORT/docs"
    echo "   • ReDoc: http://localhost:$API_PORT/redoc"
    echo ""
    echo -e "${BOLD}🧪 Test Commands:${NC}"
    echo "   # Health check"
    echo "   curl http://localhost:$API_PORT/health"
    echo ""
    echo "   # Get user info (replace YOUR_TOKEN with actual Google OAuth token)"
    echo "   curl -H \"Authorization: Bearer YOUR_TOKEN\" http://localhost:$API_PORT/me"
    echo ""
    echo -e "${BOLD}📚 Next Steps:${NC}"
    echo "   1. Get a Google OAuth token from: https://developers.google.com/oauthplayground/"
    echo "   2. Test the API with the sample curl commands above"
    echo "   3. Visit http://localhost:$API_PORT/docs for interactive API documentation"
    echo ""
    echo -e "${BOLD}🛠️  Management Commands:${NC}"
    echo "   • View logs: docker-compose logs -f"
    echo "   • Stop: docker-compose down"
    echo "   • Rebuild: ./setup.sh --rebuild"
    echo "   • Clean reset: ./cleanup.sh"
    echo ""
}

# Error cleanup
cleanup_on_error() {
    print_error "Setup failed! Cleaning up..."
    docker-compose down 2>/dev/null || true
    exit 1
}

# Main setup function
main() {
    # Handle command line arguments
    local rebuild_flag=""
    case "$1" in
        --rebuild)
            rebuild_flag="--rebuild"
            ;;
        --clean)
            rebuild_flag="--clean"
            ;;
        --help|-h)
            echo "Usage: $0 [--rebuild] [--clean] [--help]"
            echo ""
            echo "Options:"
            echo "  --rebuild  Force rebuild Docker containers"
            echo "  --clean    Clean up existing containers and rebuild"
            echo "  --help     Show this help message"
            exit 0
            ;;
    esac
    
    # Set up error handling
    trap cleanup_on_error ERR
    
    # Run setup steps
    print_header
    check_prerequisites
    check_ports
    setup_environment
    start_containers $rebuild_flag
    wait_for_services
    test_api
    show_success_info
    
    print_success "🚀 $PROJECT_NAME is ready for use!"
}

# Run main function with all arguments
main "$@"