const request = require("supertest");
const app = require("../app");

describe("API Endpoints", () => {
  describe("GET /health", () => {
    it("should return health status", async () => {
      const response = await request(app).get("/health").expect(200);

      expect(response.body).toHaveProperty("status", "healthy");
      expect(response.body).toHaveProperty("timestamp");
      expect(response.body).toHaveProperty("uptime");
    });
  });

  describe("GET /api/users", () => {
    it("should return list of users", async () => {
      const response = await request(app).get("/api/users").expect(200);

      expect(response.body).toHaveProperty("users");
      expect(response.body).toHaveProperty("total");
      expect(Array.isArray(response.body.users)).toBe(true);
    });
  });

  describe("POST /api/users", () => {
    it("should create a new user", async () => {
      const newUser = {
        name: "Test User",
        email: "test@example.com",
      };

      const response = await request(app)
        .post("/api/users")
        .send(newUser)
        .expect(201);

      expect(response.body).toHaveProperty("id");
      expect(response.body.name).toBe(newUser.name);
      expect(response.body.email).toBe(newUser.email);
      expect(response.body).toHaveProperty("createdAt");
    });

    it("should return 400 for invalid data", async () => {
      const invalidUser = {
        name: "Test User",
        // missing email
      };

      const response = await request(app)
        .post("/api/users")
        .send(invalidUser)
        .expect(400);

      expect(response.body).toHaveProperty("error");
    });

    it("should return 400 for invalid email format", async () => {
      const invalidUser = {
        name: "Test User",
        email: "invalid-email",
      };

      const response = await request(app)
        .post("/api/users")
        .send(invalidUser)
        .expect(400);

      expect(response.body.message).toContain("Invalid email format");
    });
  });

  describe("GET /api/users/:id", () => {
    it("should return 404 for non-existent user", async () => {
      await request(app).get("/api/users/999").expect(404);
    });
  });

  describe("DELETE /api/users/:id", () => {
    it("should return 404 for non-existent user", async () => {
      await request(app).get("/api/users/999").expect(404);
    });
  });

  describe("404 Handler", () => {
    it("should return 404 for unknown routes", async () => {
      const response = await request(app).get("/unknown-route").expect(404);

      expect(response.body).toHaveProperty("error", "Not found");
    });
  });
});
