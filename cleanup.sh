#!/bin/bash

# Stock Watchlist API - Cleanup Script
# Usage: ./cleanup.sh [--all] [--volumes] [--images]
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

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_header() {
    echo -e "${BOLD}${BLUE}"
    echo "==========================================="
    echo "  🧹 Stock Watchlist API Cleanup"
    echo "==========================================="
    echo -e "${NC}"
}

# Stop containers
stop_containers() {
    print_status "Stopping containers..."
    
    if docker-compose ps -q | grep -q .; then
        docker-compose stop
        print_success "Containers stopped"
    else
        print_status "No containers running"
    fi
}

# Remove containers
remove_containers() {
    print_status "Removing containers..."
    
    if docker-compose ps -a -q | grep -q .; then
        docker-compose rm -f
        print_success "Containers removed"
    else
        print_status "No containers to remove"
    fi
}

# Remove volumes
remove_volumes() {
    print_status "Removing volumes (this will delete all database data)..."
    
    read -p "Are you sure you want to delete all data? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker-compose down -v 2>/dev/null || true
        
        # Also remove named volumes
        local volumes=$(docker volume ls -q --filter name=stock-watch-list-rest-fast-api-mysql)
        if [ -n "$volumes" ]; then
            echo $volumes | xargs docker volume rm 2>/dev/null || true
            print_success "Volumes removed"
        else
            print_status "No volumes to remove"
        fi
    else
        print_status "Volume removal cancelled"
    fi
}

# Remove images
remove_images() {
    print_status "Removing Docker images..."
    
    # Remove built images for this project
    local images=$(docker images --filter reference="stock-watch-list-*" -q)
    if [ -n "$images" ]; then
        echo $images | xargs docker rmi -f 2>/dev/null || true
        print_success "Project images removed"
    fi
    
    # Clean up dangling images
    docker image prune -f >/dev/null 2>&1 || true
    print_success "Dangling images cleaned up"
}

# Remove environment files
remove_env_files() {
    print_status "Cleaning up environment files..."
    
    # Keep .env but remove backups
    if [ -f ".env.bak" ]; then
        rm .env.bak
        print_success "Removed .env backup file"
    fi
    
    # Optionally remove staging/prod env files (with confirmation)
    if [ -f ".env.staging" ] || [ -f ".env.production" ]; then
        print_warning "Found staging/production environment files"
        read -p "Remove .env.staging and .env.production? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -f .env.staging .env.production
            print_success "Environment files removed"
        fi
    fi
}

# Clean Docker system
clean_docker_system() {
    print_status "Cleaning Docker system..."
    
    # Remove unused networks, containers, images, and build cache
    docker system prune -f >/dev/null 2>&1 || true
    print_success "Docker system cleaned"
}

# Reset to fresh state
reset_to_fresh() {
    print_warning "This will reset everything to a fresh state!"
    print_warning "All data, containers, volumes, and images will be removed!"
    
    read -p "Are you absolutely sure? Type 'yes' to continue: " confirmation
    
    if [ "$confirmation" = "yes" ]; then
        stop_containers
        remove_containers
        remove_volumes
        remove_images
        remove_env_files
        clean_docker_system
        
        print_success "🧹 Complete cleanup finished!"
        print_status "Run ./setup.sh to start fresh"
    else
        print_error "Reset cancelled"
        exit 1
    fi
}

# Show cleanup options
show_status() {
    print_status "Current system status:"
    
    echo ""
    echo "📦 Containers:"
    if docker-compose ps -a -q | grep -q .; then
        docker-compose ps
    else
        echo "  No containers found"
    fi
    
    echo ""
    echo "💾 Volumes:"
    local volumes=$(docker volume ls -q --filter name=stock-watch-list-rest-fast-api-mysql)
    if [ -n "$volumes" ]; then
        docker volume ls --filter name=stock-watch-list-rest-fast-api-mysql
    else
        echo "  No project volumes found"
    fi
    
    echo ""
    echo "🖼️  Images:"
    local images=$(docker images --filter reference="stock-watch-list-*" --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}")
    if [ -n "$images" ]; then
        echo "$images"
    else
        echo "  No project images found"
    fi
    
    echo ""
    echo "📁 Files:"
    ls -la .env* 2>/dev/null | grep -v "^total" || echo "  No environment files found"
}

# Partial cleanup functions
cleanup_containers_only() {
    print_status "Cleaning up containers only..."
    stop_containers
    remove_containers
    print_success "Container cleanup complete"
}

cleanup_with_volumes() {
    print_status "Cleaning up containers and volumes..."
    stop_containers
    remove_containers
    remove_volumes
    print_success "Container and volume cleanup complete"
}

cleanup_with_images() {
    print_status "Cleaning up containers, volumes, and images..."
    stop_containers
    remove_containers
    remove_volumes
    remove_images
    print_success "Full cleanup complete (except environment files)"
}

# Main cleanup function
main() {
    print_header
    
    case "$1" in
        "--all"|"--reset")
            reset_to_fresh
            ;;
        "--volumes")
            cleanup_with_volumes
            ;;
        "--images")
            cleanup_with_images
            ;;
        "--containers")
            cleanup_containers_only
            ;;
        "--status")
            show_status
            ;;
        "--help"|"-h"|"")
            echo "Usage: $0 [option]"
            echo ""
            echo "Options:"
            echo "  --containers    Stop and remove containers only"
            echo "  --volumes       Stop containers and remove volumes (deletes data)"
            echo "  --images        Remove containers, volumes, and images"
            echo "  --all, --reset  Complete reset to fresh state"
            echo "  --status        Show current system status"
            echo "  --help, -h      Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0 --containers  # Quick cleanup, keep data"
            echo "  $0 --volumes     # Remove data too"
            echo "  $0 --all         # Full reset"
            echo "  $0 --status      # Check what's running"
            echo ""
            if [ "$1" != "--help" ] && [ "$1" != "-h" ]; then
                echo "🤔 No option specified. What would you like to clean up?"
                echo ""
                read -p "1) Containers only  2) + Volumes  3) + Images  4) Everything  5) Show status  [1]: " choice
                choice=${choice:-1}
                
                case $choice in
                    1) cleanup_containers_only ;;
                    2) cleanup_with_volumes ;;
                    3) cleanup_with_images ;;
                    4) reset_to_fresh ;;
                    5) show_status ;;
                    *) print_error "Invalid choice"; exit 1 ;;
                esac
            fi
            ;;
        *)
            print_error "Unknown option: $1"
            echo "Use: $0 --help for available options"
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"