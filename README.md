# My Kubernetes Learning App

A sample Node.js REST API for learning Docker and Kubernetes fundamentals.

## Project Structure

```
my-k8s-app/
├── app/                 # Node.js application
│   ├── app.js          # Main application file
│   ├── package.json    # Dependencies
│   └── tests/          # Test files
├── docker/              # Dockerfile + scripts
├── k8s/                # Kubernetes manifests
├── monitoring/          # Prometheus configs
└── docs/               # Learning notes
```

## Phase 1: Foundation Setup ✅

### API Endpoints

- `GET /health` - Health check endpoint
- `GET /api/users` - Get all users
- `GET /api/users/:id` - Get user by ID
- `POST /api/users` - Create new user
- `DELETE /api/users/:id` - Delete user

### Features

- ✅ RESTful API with Express.js
- ✅ Structured JSON logging
- ✅ Error handling middleware
- ✅ Input validation
- ✅ Graceful shutdown handling
- ✅ Health check endpoint
- ✅ Basic test coverage

## Quick Start

1. Navigate to the app directory:
   ```bash
   cd app
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Run the application:
   ```bash
   npm start
   ```

4. Test the application:
   ```bash
   npm test
   ```

## Testing the API

### Health Check
```bash
curl http://localhost:3000/health
```

### Get Users
```bash
curl http://localhost:3000/api/users
```

### Create User
```bash
curl -X POST http://localhost:3000/api/users \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com"}'
```

## Next Steps

- Phase 2: Docker containerization
- Phase 3: Kubernetes deployment
- Phase 4: Production readiness

## Learning Notes

Document your learning progress in the `docs/` directory.
