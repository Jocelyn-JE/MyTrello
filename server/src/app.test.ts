import request from "supertest";
import express from "express";

// Routes
import swaggerRouter from "./routes/swagger.router";

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
