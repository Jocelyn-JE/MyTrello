import request from "supertest";
import express from "express";

// Routes
import swaggerRouter from "./routes/swagger.router";
import registerRouter from "./routes/register.router";
import loginRouter from "./routes/login.router";
import boardRouter from "./routes/board.router";

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
    testApp.use("/api/login", loginRouter);
    // Board routes
    testApp.use("/api/boards", boardRouter);
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
    expect(res.body).toHaveProperty("error", "Request body is required");
});

test('"POST /api/register" with missing fields returns 400', async () => {
    const res = await request(testApp).post("/api/register").send({
        email: "",
        password: "",
        username: ""
    });
    expect(res.status).toBe(400);
    expect(res.body).toHaveProperty(
        "error",
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
    expect(res.body).toHaveProperty("error", "Invalid email format");
});

test('"POST /api/register" with valid data returns 500', async () => {
    const res = await request(testApp).post("/api/register").send({
        email: "valid@email.com",
        password: "validPassword123",
        username: "validUsername"
    });
    // Since the database is not set up in this test, we expect a 500 error
    expect(res.status).toBe(500);
    expect(res.body).toHaveProperty("error", "Internal server error");
});

// Login endpoint tests
test('"POST /api/login" with empty body returns 400', async () => {
    const res = await request(testApp).post("/api/login").send({});
    expect(res.status).toBe(400);
    expect(res.body).toHaveProperty("error", "Request body is required");
});

test('"POST /api/login" with missing fields returns 400', async () => {
    const res = await request(testApp).post("/api/login").send({
        email: "",
        password: ""
    });
    expect(res.status).toBe(400);
    expect(res.body).toHaveProperty(
        "error",
        "All fields must contain non-empty values"
    );
});

test('"POST /api/login" with invalid email returns 400', async () => {
    const res = await request(testApp).post("/api/login").send({
        email: "invalid-email",
        password: "validPassword123"
    });
    expect(res.status).toBe(400);
    expect(res.body).toHaveProperty("error", "Invalid email format");
});

test('"POST /api/login" with valid data returns 500', async () => {
    const res = await request(testApp).post("/api/login").send({
        email: "valid@email.com",
        password: "validPassword123"
    });
    // Since the database is not set up in this test, we expect a 500 error
    expect(res.status).toBe(500);
    expect(res.body).toHaveProperty("error", "Internal server error");
});

// Board endpoint tests
test('"POST /api/boards" without token returns 401', async () => {
    const res = await request(testApp).post("/api/boards").send({
        title: "Test Board",
        users: []
    });
    expect(res.status).toBe(401);
    expect(res.body).toHaveProperty("error", "No token provided");
});

test('"POST /api/boards" with invalid token returns 401', async () => {
    const res = await request(testApp)
        .post("/api/boards")
        .set("Authorization", "Bearer invalid-token")
        .send({
            title: "Test Board",
            users: []
        });
    expect(res.status).toBe(401);
    expect(res.body).toHaveProperty("error", "Invalid token");
});

test('"POST /api/boards" with empty body returns 401 (invalid token)', async () => {
    const res = await request(testApp)
        .post("/api/boards")
        .set("Authorization", "Bearer valid-jwt-token")
        .send({});
    // JWT verification happens first, so invalid token returns 401
    expect(res.status).toBe(401);
    expect(res.body).toHaveProperty("error", "Invalid token");
});

test('"POST /api/boards" with missing fields returns 401 (invalid token)', async () => {
    const res = await request(testApp)
        .post("/api/boards")
        .set("Authorization", "Bearer valid-jwt-token")
        .send({
            title: "",
            users: []
        });
    // JWT verification happens first, so invalid token returns 401
    expect(res.status).toBe(401);
    expect(res.body).toHaveProperty("error", "Invalid token");
});

// Note: More comprehensive tests would require a test database setup
// and teardown to handle user creation, uniqueness checks, etc.
