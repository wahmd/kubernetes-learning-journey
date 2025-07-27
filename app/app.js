const express = require("express");
const morgan = require("morgan");
const { v4: uuidv4 } = require("uuid");

const app = express();
const port = process.env.PORT || 3000;

// Middleware
app.use(express.json());
app.use(morgan("combined"));

// Mock data store (in-memory)
let users = [
  {
    id: "1",
    name: "John Doe",
    email: "john@example.com",
    createdAt: new Date().toISOString(),
  },
  {
    id: "2",
    name: "Jane Smith",
    email: "jane@example.com",
    createdAt: new Date().toISOString(),
  },
];

// Logging utility
const logger = {
  info: (message, data = {}) => {
    console.log(
      JSON.stringify({
        level: "info",
        message,
        timestamp: new Date().toISOString(),
        ...data,
      })
    );
  },
  error: (message, error = {}) => {
    console.error(
      JSON.stringify({
        level: "error",
        message,
        error: error.message || error,
        stack: error.stack,
        timestamp: new Date().toISOString(),
      })
    );
  },
};

// Error handling middleware
const errorHandler = (err, req, res, next) => {
  logger.error("Unhandled error", err);
  res.status(500).json({
    error: "Internal server error",
    message:
      process.env.NODE_ENV === "development"
        ? err.message
        : "Something went wrong",
  });
};

// Validation middleware
const validateUser = (req, res, next) => {
  const { name, email } = req.body;

  if (!name || !email) {
    return res.status(400).json({
      error: "Validation failed",
      message: "Name and email are required",
    });
  }

  if (!email.includes("@")) {
    return res.status(400).json({
      error: "Validation failed",
      message: "Invalid email format",
    });
  }

  next();
};

// Routes
// Health check endpoint
app.get("/health", (req, res) => {
  const healthData = {
    status: "healthy",
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    version: process.env.npm_package_version || "1.0.0",
    environment: process.env.NODE_ENV || "development",
  };

  logger.info("Health check requested", { status: "healthy" });
  res.json(healthData);
});

// Get all users
app.get("/api/users", (req, res) => {
  try {
    logger.info("Fetching all users", { count: users.length });
    res.json({
      users,
      total: users.length,
      timestamp: new Date().toISOString(),
    });
  } catch (error) {
    logger.error("Error fetching users", error);
    res.status(500).json({ error: "Failed to fetch users" });
  }
});

// Get user by ID
app.get("/api/users/:id", (req, res) => {
  try {
    const { id } = req.params;
    const user = users.find((u) => u.id === id);

    if (!user) {
      logger.info("User not found", { userId: id });
      return res.status(404).json({ error: "User not found" });
    }

    logger.info("User fetched", { userId: id });
    res.json(user);
  } catch (error) {
    logger.error("Error fetching user", error);
    res.status(500).json({ error: "Failed to fetch user" });
  }
});

// Create new user
app.post("/api/users", validateUser, (req, res) => {
  try {
    const { name, email } = req.body;

    // Check if user already exists
    const existingUser = users.find((u) => u.email === email);
    if (existingUser) {
      logger.info("User creation failed - email exists", { email });
      return res.status(409).json({
        error: "Conflict",
        message: "User with this email already exists",
      });
    }

    const newUser = {
      id: uuidv4(),
      name,
      email,
      createdAt: new Date().toISOString(),
    };

    users.push(newUser);
    logger.info("User created successfully", { userId: newUser.id, email });

    res.status(201).json(newUser);
  } catch (error) {
    logger.error("Error creating user", error);
    res.status(500).json({ error: "Failed to create user" });
  }
});

// Delete user
app.delete("/api/users/:id", (req, res) => {
  try {
    const { id } = req.params;
    const userIndex = users.findIndex((u) => u.id === id);

    if (userIndex === -1) {
      logger.info("User deletion failed - not found", { userId: id });
      return res.status(404).json({ error: "User not found" });
    }

    const deletedUser = users.splice(userIndex, 1)[0];
    logger.info("User deleted successfully", { userId: id });

    res.json({ message: "User deleted successfully", user: deletedUser });
  } catch (error) {
    logger.error("Error deleting user", error);
    res.status(500).json({ error: "Failed to delete user" });
  }
});

// 404 handler
app.use("*", (req, res) => {
  logger.info("Route not found", { path: req.originalUrl, method: req.method });
  res.status(404).json({
    error: "Not found",
    message: `Route ${req.method} ${req.originalUrl} not found`,
  });
});

// Error handling middleware (must be last)
app.use(errorHandler);

let server;

// Only start the server if this file is run directly, not when imported (fixes test open handle issue)
if (require.main === module) {
  // Start server
  server = app.listen(port, () => {
    logger.info("Server started", {
      port,
      environment: process.env.NODE_ENV || "development",
      nodeVersion: process.version,
    });
  });
}

// Graceful shutdown handling
const gracefulShutdown = (signal) => {
  logger.info(`Received ${signal}, shutting down gracefully`);
  server?.close(() => {
    logger.info("Server closed");
    process.exit(0);
  });

  // Force close after 10s
  setTimeout(() => {
    logger.error("Forced shutdown");
    process.exit(1);
  }, 10000);
};

// Handle shutdown signals
process.on("SIGTERM", () => gracefulShutdown("SIGTERM"));
process.on("SIGINT", () => gracefulShutdown("SIGINT"));

module.exports = app;
