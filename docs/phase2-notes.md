# Docker Phase 2 - What I Learned

## Multi-stage builds

- Builder stage: install everything, run tests
- Production stage: copy only what's needed
- Final image is way smaller

## Package files first

```dockerfile
COPY package*.json ./
RUN npm ci
COPY app/ .
```

- Docker caches layers
- Package files change less than code
- Faster rebuilds

## Don't run as root

```dockerfile
RUN adduser nodeuser
USER nodeuser
```

- Security risk otherwise
- Most containers get hacked because of root access

## Health checks matter

- Container can run but app can be broken
- Kubernetes needs this to know if pod is actually working
- Simple HTTP check is enough

## Test during build

- If tests fail, build fails
- Catches problems before deployment
- Better than finding out in production

## Set NODE_ENV=production

- Node runs faster
- Disables debug stuff
- Should always do this

## Own your directories

```dockerfile
RUN chown -R nodeuser:nodejs /app
```

- Non-root user needs write permissions
- Logs directory especially important
