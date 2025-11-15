#!/bin/bash

# Stock Watchlist API - Deployment Script
# Usage: ./deploy.sh [production|staging|local]
# Author: CS640 Project

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Print colored output
print_status() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_header() {
    local env=${1:-"local"}
    echo -e "${BOLD}${BLUE}"
    echo "==========================================="
    echo "  🚀 Stock Watchlist API Deployment"
    echo "  📦 Environment: $env"
    echo "==========================================="
    echo -e "${NC}"
}

# Deploy to different environments
deploy_local() {
    print_status "Deploying to local development environment..."
    
    # Ensure DEBUG is enabled for local
    if [ -f ".env" ]; then
        sed -i.bak 's/DEBUG=false/DEBUG=true/g' .env
        print_success "Enabled DEBUG mode for local development"
    fi
    
    # Use setup.sh for local deployment
    ./setup.sh --rebuild
}

deploy_staging() {
    print_status "Deploying to staging environment..."
    
    # Create staging environment file
    if [ ! -f ".env.staging" ]; then
        print_error ".env.staging file not found!"
        print_status "Creating template .env.staging file..."
        
        cat > .env.staging << EOF
# MySQL Configuration - Staging
MYSQL_ROOT_PASSWORD=staging_root_password_change_me
MYSQL_DATABASE=stockwatchlist_staging
MYSQL_USER=staging_user
MYSQL_PASSWORD=staging_password_change_me

# Google OAuth Configuration - Staging
GOOGLE_CLIENT_ID=your-staging-client-id.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=your-staging-client-secret

# FastAPI Configuration
DATABASE_URL=mysql+pymysql://staging_user:staging_password_change_me@mysql:3306/stockwatchlist_staging

# Debug Mode
DEBUG=false
EOF
        print_error "Please edit .env.staging with your staging credentials and run again."
        exit 1
    fi
    
    # Copy staging env to .env
    cp .env.staging .env
    
    # Deploy with production-like settings
    docker-compose -f docker-compose.yml -f docker-compose.staging.yml up -d --build
    
    print_success "Deployed to staging environment"
    print_status "Staging URL: http://your-staging-server:8000"
}

deploy_production() {
    print_status "Deploying to production environment..."
    
    # Confirmation prompt
    echo -e "${YELLOW}⚠️  You are about to deploy to PRODUCTION!${NC}"
    read -p "Are you sure? Type 'yes' to continue: " confirmation
    
    if [ "$confirmation" != "yes" ]; then
        print_error "Production deployment cancelled."
        exit 1
    fi
    
    # Check for production environment file
    if [ ! -f ".env.production" ]; then
        print_error ".env.production file not found!"
        print_status "Creating template .env.production file..."
        
        cat > .env.production << EOF
# MySQL Configuration - Production
MYSQL_ROOT_PASSWORD=production_root_password_CHANGE_ME
MYSQL_DATABASE=stockwatchlist
MYSQL_USER=produser
MYSQL_PASSWORD=production_password_CHANGE_ME

# Google OAuth Configuration - Production
GOOGLE_CLIENT_ID=your-production-client-id.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=your-production-client-secret

# FastAPI Configuration
DATABASE_URL=mysql+pymysql://produser:production_password_CHANGE_ME@mysql:3306/stockwatchlist

# Debug Mode - NEVER true in production
DEBUG=false
EOF
        print_error "Please edit .env.production with your production credentials and run again."
        exit 1
    fi
    
    # Copy production env to .env
    cp .env.production .env
    
    # Ensure DEBUG is disabled
    sed -i.bak 's/DEBUG=true/DEBUG=false/g' .env
    
    # Deploy with production settings
    docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build --no-cache
    
    # Run production health checks
    sleep 10
    if curl -f http://localhost:8000/health > /dev/null 2>&1; then
        print_success "Production deployment successful!"
        print_success "API is healthy at http://localhost:8000"
    else
        print_error "Production deployment failed health check!"
        docker-compose logs --tail=20
        exit 1
    fi
}

# Create production docker-compose override if it doesn't exist
create_production_compose() {
    if [ ! -f "docker-compose.prod.yml" ]; then
        print_status "Creating production docker-compose override..."
        
        cat > docker-compose.prod.yml << EOF
services:
  fastapi:
    restart: unless-stopped
    environment:
      - DEBUG=false
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 60s

  mysql:
    restart: unless-stopped
    command: --innodb-buffer-pool-size=256M --max-connections=100
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 60s
EOF
        print_success "Created docker-compose.prod.yml"
    fi
}

# Create staging docker-compose override if it doesn't exist
create_staging_compose() {
    if [ ! -f "docker-compose.staging.yml" ]; then
        print_status "Creating staging docker-compose override..."
        
        cat > docker-compose.staging.yml << EOF
services:
  fastapi:
    environment:
      - DEBUG=false
    ports:
      - "8001:8000"  # Different port for staging

  mysql:
    ports:
      - "3307:3306"  # Different port for staging
EOF
        print_success "Created docker-compose.staging.yml"
    fi
}

# Show deployment status
show_status() {
    print_status "Checking deployment status..."
    
    echo "📊 Container Status:"
    docker-compose ps
    
    echo ""
    echo "🔗 Service URLs:"
    echo "  • API: http://localhost:8000"
    echo "  • Docs: http://localhost:8000/docs"
    
    echo ""
    echo "📋 Health Checks:"
    
    # Check API health
    if curl -s http://localhost:8000/health > /dev/null 2>&1; then
        echo "  • API: ✅ Healthy"
    else
        echo "  • API: ❌ Unhealthy"
    fi
    
    # Check database
    if docker-compose exec -T mysql mysqladmin ping -h localhost --silent 2>/dev/null; then
        echo "  • Database: ✅ Healthy"
    else
        echo "  • Database: ❌ Unhealthy"
    fi
}

# Main deployment function
main() {
    local environment=${1:-"local"}
    
    print_header $environment
    
    case $environment in
        "local")
            deploy_local
            ;;
        "staging")
            create_staging_compose
            deploy_staging
            ;;
        "production"|"prod")
            create_production_compose
            deploy_production
            ;;
        "status")
            show_status
            exit 0
            ;;
        "help"|"-h"|"--help")
            echo "Usage: $0 [local|staging|production|status|help]"
            echo ""
            echo "Environments:"
            echo "  local       Deploy for local development (default)"
            echo "  staging     Deploy to staging environment"
            echo "  production  Deploy to production environment"
            echo "  status      Show current deployment status"
            echo "  help        Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0              # Deploy locally"
            echo "  $0 local        # Deploy locally with debug enabled"
            echo "  $0 staging      # Deploy to staging"
            echo "  $0 production   # Deploy to production"
            echo "  $0 status       # Check deployment status"
            exit 0
            ;;
        *)
            print_error "Unknown environment: $environment"
            echo "Use: $0 help for available options"
            exit 1
            ;;
    esac
    
    echo ""
    print_success "🎉 Deployment to $environment completed!"
    
    # Show status after deployment
    show_status
}

# Run main function with all arguments
main "$@"