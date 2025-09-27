import request from "supertest";
import express from "express";

// Routes
import swaggerRouter from "./routes/swagger.router";
import registerRouter from "./routes/register.router";

const testApp = express();

beforeAll(() => {
    testApp.use(express.json());
    testApp.use(express.urlencoded({ extended: true }));
    // Test route
    testApp.get("/", (req, res) => {
        res.send("Server is running");
    });
    // Documentation route
    testApp.use("/api-docs", swaggerRouter);
    // User routes
    testApp.use("/api/register", registerRouter);
});

test('"GET /" returns 200 and "Server is running"', async () => {
    const res = await request(testApp).get("/");
    expect(res.status).toBe(200);
    expect(res.text).toBe("Server is running");
});

test('"GET /api-docs/" returns 200 and serves swagger UI', async () => {
    const res = await request(testApp).get("/api-docs/");
    expect(res.status).toBe(200);
    expect(res.text).toContain("MyTrello API Documentation");
    expect(res.text).toContain("swagger-ui");
});

test('"GET /api-docs/swagger.json" returns 200 and serves swagger JSON', async () => {
    const res = await request(testApp).get("/api-docs/swagger.json");
    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty("openapi");
    expect(res.body).toHaveProperty("info");
    expect(res.body).toHaveProperty("paths");
});

test('"POST /api/register" with empty body returns 400', async () => {
    const res = await request(testApp).post("/api/register").send({});
    expect(res.status).toBe(400);
    expect(res.body).toHaveProperty("message", "Request body is required");
});

test('"POST /api/register" with missing fields returns 400', async () => {
    const res = await request(testApp).post("/api/register").send({
        email: "",
        password: "",
        username: ""
    });
    expect(res.status).toBe(400);
    expect(res.body).toHaveProperty(
        "message",
        "All fields must contain non-empty values"
    );
});

test('"POST /api/register" with invalid email returns 400', async () => {
    const res = await request(testApp).post("/api/register").send({
        email: "invalid-email",
        password: "validPassword123",
        username: "validUsername"
    });
    expect(res.status).toBe(400);
    expect(res.body).toHaveProperty("message", "Invalid email format");
});

test('"POST /api/register" with valid data returns 500', async () => {
    const res = await request(testApp).post("/api/register").send({
        email: "valid@email.com",
        password: "validPassword123",
        username: "validUsername"
    });
    // Since the database is not set up in this test, we expect a 500 error
    expect(res.status).toBe(500);
    expect(res.body).toHaveProperty("message", "Internal server error");
});

// Note: More comprehensive tests would require a test database setup
// and teardown to handle user creation, uniqueness checks, etc.
