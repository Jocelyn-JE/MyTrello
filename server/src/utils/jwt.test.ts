import express from "express";
import request from "supertest";
import jwt from "jsonwebtoken";
import { generateToken, JwtPayload, verifyToken } from "./jwt";
import { Request, Response, NextFunction } from "express";

describe("JWT utilities", () => {
    const SECRET = "your_jwt_secret";

    describe("generateToken", () => {
        const FIXED_NOW = 1700000000000; // fixed timestamp

        // Replace Date.now with a fixed value
        beforeAll(() => {
            jest.spyOn(Date, "now").mockReturnValue(FIXED_NOW);
        });

        // Restore Date.now after tests
        afterAll(() => {
            (Date.now as jest.Mock).mockRestore();
        });

        it("should generate a valid JWT containing userId and correct expiresAt", () => {
            const userId = "uuid-123";
            const token = generateToken(userId);
            expect(typeof token).toBe("string");

            const decoded = jwt.verify(token, SECRET) as JwtPayload;
            expect(decoded.userId).toBe(userId);
            expect(decoded.expiresAt).toBe(FIXED_NOW + 3600000);
        });
    });

    describe("verifyToken middleware (unit)", () => {
        const runMiddleware = (authHeader?: string, _tokenOverride?: string) =>
            new Promise<{
                status?: number;
                body?: unknown;
                nextCalled: boolean;
            }>((resolve) => {
                const req = {
                    headers: {} as Record<string, string>,
                    method: "GET" as const,
                    url: "/"
                } as Partial<Request>;

                if (authHeader && req.headers)
                    req.headers.authorization = authHeader;

                const result: {
                    status?: number;
                    body?: unknown;
                    nextCalled: boolean;
                } = {
                    nextCalled: false
                };

                const res = {
                    status(code: number) {
                        result.status = code;
                        return this;
                    },
                    send(payload: unknown) {
                        result.body = payload;
                        resolve(result);
                        return this;
                    }
                } as Partial<Response>;

                const next: NextFunction = () => {
                    result.nextCalled = true;
                    result.status = 200;
                    resolve(result);
                };

                verifyToken(req as Request, res as Response, next);
            });

        it("should return 401 when no Authorization header is provided", async () => {
            const r = await runMiddleware();
            expect(r.status).toBe(401);
            expect(r.body).toEqual({ error: "No token provided" });
        });

        it("should return 401 when token is malformed", async () => {
            const r = await runMiddleware("Bearer invalid.token.here");
            expect(r.status).toBe(401);
            expect(r.body).toEqual({ error: "Invalid token" });
        });

        it("should return 401 when token is expired", async () => {
            const expiredPayload = { userId: 5, expiresAt: Date.now() - 1000 };
            const expiredToken = jwt.sign(expiredPayload, SECRET);
            const r = await runMiddleware(`Bearer ${expiredToken}`);
            expect(r.status).toBe(401);
            expect(r.body).toEqual({ error: "Token has expired" });
        });

        it("should call next and attach userId for a valid token", async () => {
            const token = generateToken("uuid-77");
            const r = await runMiddleware(`Bearer ${token}`);
            expect(r.status).toBe(200);
            expect(r.nextCalled).toBe(true);
        });

        it(`should return 401 when token is not provided after "Bearer"`, async () => {
            const r = await runMiddleware(`Bearer `);
            expect(r.status).toBe(401);
            expect(r.nextCalled).toBe(false);
            expect(r.body).toEqual({ error: "No token provided" });
        });
    });

    describe("verifyToken middleware (integration with Express)", () => {
        const app = express();
        app.get("/protected", verifyToken, (req, res) => {
            res.json({ userId: req.userId, ok: true });
        });

        it("should succeed on /protected with valid token", async () => {
            const token = generateToken("uuid-999");
            const res = await request(app)
                .get("/protected")
                .set("Authorization", `Bearer ${token}`)
                .expect(200);
            expect(res.body).toEqual({ userId: "uuid-999", ok: true });
        });

        it("should fail on /protected without token", async () => {
            const res = await request(app).get("/protected").expect(401);
            expect(res.body).toEqual({ error: "No token provided" });
        });

        it("should fail on /protected with invalid token", async () => {
            const res = await request(app)
                .get("/protected")
                .set("Authorization", "Bearer abc.def.ghi")
                .expect(401);
            expect(res.body).toEqual({ error: "Invalid token" });
        });
    });
});
