#!/bin/bash

# Docker Management Scripts for Phase 2
set -e

APP_NAME="k8s-learning-app"
IMAGE_NAME="$APP_NAME"
# Only set version if second parameter is provided, otherwise use latest
if [ "$1" = "build" ] && [ -n "$2" ]; then
    VERSION="$2"
elif [ "$1" != "build" ] && [ -n "$2" ]; then
    VERSION="$2"
else
    VERSION="latest"
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}🐳 Docker Management - $1${NC}"
    echo "=================================="
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

# Function to build the Docker image
build_image() {
    print_header "Building Docker Image"
    
    echo "📦 Building production image..."
    docker build -f docker/Dockerfile -t $IMAGE_NAME:$VERSION .
    
    print_success "Image built successfully: $IMAGE_NAME:$VERSION"
    
    # Show image size
    echo "📊 Image size:"
    docker images $IMAGE_NAME:$VERSION
}

# Function to build development image
build_dev() {
    print_header "Building Development Image"
    
    echo "🛠️  Building development image..."
    docker build -f docker/Dockerfile.dev -t $IMAGE_NAME:dev .
    
    print_success "Development image built: $IMAGE_NAME:dev"
}

# Function to run the container
run_container() {
    print_header "Running Container"
    
    # Stop existing container if running
    if docker ps -q -f name=$APP_NAME | grep -q .; then
        echo "🛑 Stopping existing container..."
        docker stop $APP_NAME
        docker rm $APP_NAME
    fi
    
    echo "🚀 Starting new container..."
    docker run -d \
        --name $APP_NAME \
        -p 3000:3000 \
        -e NODE_ENV=production \
        --restart unless-stopped \
        $IMAGE_NAME:$VERSION
    
    print_success "Container started: $APP_NAME"
    
    # Wait for health check
    echo "⏳ Waiting for application to be ready..."
    sleep 5
    
    # Test health endpoint
    if curl -f http://localhost:3000/health > /dev/null 2>&1; then
        print_success "Application is healthy!"
        echo "🔗 Access your application at: http://localhost:3000"
    else
        print_warning "Health check failed. Check container logs:"
        echo "   docker logs $APP_NAME"
    fi
}

# Function to run development container
run_dev() {
    print_header "Running Development Container"
    
    echo "🛠️  Starting development container with hot reload..."
    docker-compose --profile dev up -d app-dev
    
    print_success "Development container started"
    echo "🔗 Access your application at: http://localhost:3001"
    echo "📝 Files are mounted for hot reload"
}

# Function to run tests in container
test_container() {
    print_header "Running Tests in Container"
    
    echo "🧪 Running tests..."
    docker run --rm $IMAGE_NAME:$VERSION npm test
    
    print_success "Tests completed"
}

# Function to scan for security vulnerabilities
security_scan() {
    print_header "Security Scanning"
    
    # Check if docker scout is available
    if command -v docker scout &> /dev/null; then
        echo "🔍 Running Docker Scout security scan..."
        docker scout cves $IMAGE_NAME:$VERSION
    else
        print_warning "Docker Scout not available. Install with: docker scout version"
        echo "🔍 Running basic vulnerability scan with docker history..."
        docker history $IMAGE_NAME:$VERSION
    fi
}

# Function to optimize and analyze image
analyze_image() {
    print_header "Image Analysis"
    
    echo "📊 Image layers and size:"
    docker history $IMAGE_NAME:$VERSION
    
    echo ""
    echo "📋 Image details:"
    docker inspect $IMAGE_NAME:$VERSION | jq '.[0] | {
        Created: .Created,
        Size: .Size,
        Architecture: .Architecture,
        Os: .Os,
        Config: {
            User: .Config.User,
            ExposedPorts: .Config.ExposedPorts,
            Env: .Config.Env,
            Cmd: .Config.Cmd,
            Healthcheck: .Config.Healthcheck
        }
    }'
}

# Function to show container logs
show_logs() {
    print_header "Container Logs"
    
    if docker ps -q -f name=$APP_NAME | grep -q .; then
        echo "📄 Following logs for $APP_NAME (Ctrl+C to exit):"
        docker logs -f $APP_NAME
    else
        print_error "Container $APP_NAME is not running"
    fi
}

# Function to clean up Docker resources
cleanup() {
    print_header "Cleanup"
    
    echo "🧹 Stopping and removing containers..."
    docker-compose down --remove-orphans
    
    echo "🗑️  Removing unused images..."
    docker image prune -f
    
    echo "🧽 Removing unused volumes..."
    docker volume prune -f
    
    print_success "Cleanup completed"
}

# Function to show container stats
stats() {
    print_header "Container Statistics"
    
    if docker ps -q -f name=$APP_NAME | grep -q .; then
        echo "📊 Real-time stats for $APP_NAME:"
        docker stats $APP_NAME
    else
        print_error "Container $APP_NAME is not running"
    fi
}

# Main script logic
case "$1" in
    build)
        build_image
        ;;
    build-dev)
        build_dev
        ;;
    run)
        run_container
        ;;
    run-dev)
        run_dev
        ;;
    test)
        test_container
        ;;
    scan)
        security_scan
        ;;
    analyze)
        analyze_image
        ;;
    logs)
        show_logs
        ;;
    stats)
        stats
        ;;
    cleanup)
        cleanup
        ;;
    *)
        echo "🐳 Docker Management Script"
        echo ""
        echo "Usage: $0 {build|build-dev|run|run-dev|test|scan|analyze|logs|stats|cleanup}"
        echo ""
        echo "Commands:"
        echo "  build      - Build production Docker image"
        echo "  build-dev  - Build development Docker image"
        echo "  run        - Run production container"
        echo "  run-dev    - Run development container with hot reload"
        echo "  test       - Run tests in container"
        echo "  scan       - Security scan with Docker Scout"
        echo "  analyze    - Analyze image layers and details"
        echo "  logs       - Show container logs"
        echo "  stats      - Show container statistics"
        echo "  cleanup    - Clean up Docker resources"
        echo ""
        echo "Examples:"
        echo "  $0 build           # Build with latest tag"
        echo "  $0 build v1.0.0    # Build with specific version"
        echo "  $0 run             # Run latest version"
        echo "  $0 run v1.0.0      # Run specific version"
        exit 1
        ;;
esac