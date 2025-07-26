#!/bin/bash

# Git Setup Script for Kubernetes Learning Project
echo "🔧 Setting up Git repository for my-k8s-app"

# Navigate to project root
cd my-k8s-app

# Initialize git repository
echo "📁 Initializing Git repository..."
git init

# Create comprehensive .gitignore
echo "📝 Creating .gitignore..."
cat > .gitignore << 'EOF'
# Node.js
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
package-lock.json

# Environment variables
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Logs
logs/
*.log

# Runtime data
pids/
*.pid
*.seed
*.pid.lock

# Coverage directory used by tools like istanbul
coverage/
.nyc_output/

# Dependency directories
jspm_packages/

# Optional npm cache directory
.npm

# Optional REPL history
.node_repl_history

# Output of 'npm pack'
*.tgz

# Yarn Integrity file
.yarn-integrity

# IDE files
.vscode/settings.json
.vscode/launch.json
.idea/
*.swp
*.swo
*~

# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Docker
.dockerignore
*.dockerfile.swp

# Kubernetes
*.tmp
.kube/cache/
.kube/http-cache/

# Monitoring and logs
prometheus/data/
grafana/data/

# Temporary files
temp/
tmp/
*.temp

# Build artifacts
dist/
build/
EOF

# Add all files
echo "➕ Adding files to Git..."
git add .

# Create initial commit
echo "💾 Creating initial commit..."
git commit -m "Phase 1: Foundation Setup - Node.js REST API

✅ Features implemented:
- RESTful API with Express.js
- Health check endpoint (/health)
- User CRUD operations (/api/users)
- Structured JSON logging
- Error handling middleware
- Input validation
- Graceful shutdown handling
- Comprehensive test coverage
- Project structure for Docker/K8s phases

📊 API Endpoints:
- GET /health - Health check
- GET /api/users - List all users
- GET /api/users/:id - Get user by ID
- POST /api/users - Create new user
- DELETE /api/users/:id - Delete user

🧪 Test Coverage:
- API endpoint testing
- Error handling validation
- Input validation tests
- Health check verification

📁 Project Structure:
- app/ - Node.js application
- docker/ - Ready for Phase 2
- k8s/ - Ready for Phase 3
- monitoring/ - Ready for Phase 4
- docs/ - Learning documentation

Ready for Phase 2: Docker containerization"

echo "✅ Git repository initialized and initial commit created!"
echo ""
echo "🔗 Next steps to push to GitHub:"
echo "   1. Create a new repository on GitHub (https://github.com/new)"
echo "   2. Repository name: my-k8s-learning or similar"
echo "   3. Keep it public for learning purposes"
echo "   4. Don't initialize with README (we already have one)"
echo "   5. Run the following commands:"
echo ""
echo "   git branch -M main"
echo "   git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git"
echo "   git push -u origin main"
echo ""
echo "📋 Or copy and run this template:"
echo "   git branch -M main"
echo "   git remote add origin https://github.com/YOUR_USERNAME/my-k8s-learning.git"
echo "   git push -u origin main"