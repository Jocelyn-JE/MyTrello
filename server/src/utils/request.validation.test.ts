import request from "supertest";
import express, { Request, Response } from "express";
import {
    validateJSONRequest,
    checkExactFields,
    checkAllowedFields,
    isEmpty,
    isValidEmail
} from "./request.validation";

function createMockReq(overrides: Partial<Request> = {}): Partial<Request> {
    return {
        headers: {},
        body: {},
        ...overrides
    };
}

function createMockRes() {
    const res: Partial<Response> & {
        status: jest.Mock;
        json: jest.Mock;
        _status?: number;
        _json?: any;
    } = {
        status: jest.fn(function (this: any, code: number) {
            res._status = code;
            return this;
        }),
        json: jest.fn(function (this: any, data: any) {
            res._json = data;
            return this;
        })
    };
    return res;
}

describe("validateJSONRequest", () => {
    test("returns null for valid JSON request with application/json header", () => {
        const req = createMockReq({
            headers: { "content-type": "application/json" },
            body: { a: 1 }
        });
        const res = createMockRes();
        const result = validateJSONRequest(
            req as Request,
            res as unknown as Response
        );
        expect(result).toBeNull();
        expect(res.status).not.toHaveBeenCalled();
    });

    test("returns null when content-type is missing but body is valid", () => {
        const req = createMockReq({ body: { a: 1 } });
        const res = createMockRes();
        const result = validateJSONRequest(
            req as Request,
            res as unknown as Response
        );
        expect(result).toBeNull();
    });

    test("accepts content-type with charset", () => {
        const req = createMockReq({
            headers: { "content-type": "application/json; charset=utf-8" },
            body: { foo: "bar" }
        });
        const res = createMockRes();
        const result = validateJSONRequest(
            req as Request,
            res as unknown as Response
        );
        expect(result).toBeNull();
    });

    test("rejects non-JSON content-type", () => {
        const req = createMockReq({
            headers: { "content-type": "text/plain" },
            body: { a: 1 }
        });
        const res = createMockRes();
        validateJSONRequest(req as Request, res as unknown as Response);
        expect(res.status).toHaveBeenCalledWith(400);
        expect(res.json).toHaveBeenCalledWith({
            error: "Content-Type must be application/json"
        });
    });

    test("rejects empty object body", () => {
        const req = createMockReq({
            headers: { "content-type": "application/json" },
            body: {}
        });
        const res = createMockRes();
        validateJSONRequest(req as Request, res as unknown as Response);
        expect(res.status).toHaveBeenCalledWith(400);
        expect(res._json).toEqual({ error: "Request body is required" });
    });

    test("rejects undefined body", () => {
        const req = createMockReq({
            headers: { "content-type": "application/json" },
            body: undefined as any
        });
        const res = createMockRes();
        validateJSONRequest(req as Request, res as unknown as Response);
        expect(res.status).toHaveBeenCalledWith(400);
        expect(res._json).toEqual({ error: "Request body is required" });
    });

    test("rejects non-object body", () => {
        const req = createMockReq({
            headers: { "content-type": "application/json" },
            body: "not-an-object" as any
        });
        const res = createMockRes();
        validateJSONRequest(req as Request, res as unknown as Response);
        expect(res.status).toHaveBeenCalledWith(400);
        expect(res._json).toEqual({
            error: "Request body must be valid JSON"
        });
    });
});

describe("checkExactFields", () => {
    test("passes when body has exactly required fields in any order", () => {
        const required = ["email", "password"];
        const body = { password: "x", email: "y" };
        const res = createMockRes();
        const result = checkExactFields(
            body,
            res as unknown as Response,
            required
        );
        expect(result).toBeNull();
        expect(res.status).not.toHaveBeenCalled();
    });

    test("fails when a required field is missing", () => {
        const required = ["email", "password"];
        const body = { email: "x" };
        const res = createMockRes();
        checkExactFields(body, res as unknown as Response, required);
        expect(res.status).toHaveBeenCalledWith(400);
        // required array is sorted in-place by implementation
        expect(res._json).toEqual({
            error: "Request body must contain exactly the required fields: email, password"
        });
    });

    test("fails when extra field is present", () => {
        const required = ["email", "password"];
        const body = { email: "a", password: "b", extra: 1 };
        const res = createMockRes();
        checkExactFields(body, res as unknown as Response, required);
        expect(res.status).toHaveBeenCalledWith(400);
        expect(res._json?.error).toContain(
            "Request body must contain exactly the required fields"
        );
    });
});

describe("checkAllowedFields", () => {
    test("passes with subset of allowed fields", () => {
        const allowed = ["name", "email"];
        const body = { email: "a@b.com" };
        const res = createMockRes();
        const result = checkAllowedFields(
            body,
            res as unknown as Response,
            allowed
        );
        expect(result).toBeNull();
        expect(res.status).not.toHaveBeenCalled();
    });

    test("fails with invalid field", () => {
        const allowed = ["name", "email"];
        const body = { username: "x" };
        const res = createMockRes();
        checkAllowedFields(body, res as unknown as Response, allowed);
        expect(res.status).toHaveBeenCalledWith(400);
        expect(res._json).toEqual({
            error: "Request body contains invalid fields. Allowed fields are: name, email"
        });
    });

    test("fails with empty body", () => {
        const allowed = ["name", "email"];
        const body = {};
        const res = createMockRes();
        checkAllowedFields(body, res as unknown as Response, allowed);
        expect(res.status).toHaveBeenCalledWith(400);
        expect(res._json).toEqual({
            error: "Request body must contain at least one field to update."
        });
    });
});

describe("isEmpty", () => {
    test("returns true when all fields empty or whitespace", () => {
        expect(isEmpty("", " ", "\n")).toBe(true);
    });

    test("returns true when any field has non-whitespace", () => {
        expect(isEmpty("", "value", " ")).toBe(true);
    });

    test("returns false when all fields have non-whitespace", () => {
        expect(isEmpty("a", "b")).toBe(false);
    });
});

describe("isValidEmail", () => {
    test("valid emails", () => {
        const emails = [
            "simple@example.com",
            "very.common@example.com",
            "disposable.style.email.with+symbol@example.com",
            "user_name@example.co.uk"
        ];
        emails.forEach((e) => expect(isValidEmail(e)).toBe(true));
    });

    test("invalid emails", () => {
        const emails = [
            "plainaddress",
            "@missinglocal.org",
            "username@example..com",
            "user@.invalid.com",
            "user@invalid"
        ];
        emails.forEach((e) => expect(isValidEmail(e)).toBe(false));
    });
});

describe("Integration with Express + supertest (validateJSONRequest)", () => {
    const app = express();
    app.use(express.json());
    app.post("/validate", (req, res) => {
        const maybeError = validateJSONRequest(req, res);
        if (maybeError) return;
        res.status(200).json({ ok: true });
    });

    test("returns 400 for wrong content-type", async () => {
        await request(app)
            .post("/validate")
            .set("Content-Type", "text/plain")
            .send("hello")
            .expect(400)
            .expect((r) => {
                expect(r.body).toEqual({
                    error: "Content-Type must be application/json"
                });
            });
    });

    test("returns 200 for correct content-type + body", async () => {
        await request(app)
            .post("/validate")
            .set("Content-Type", "application/json")
            .send({ test: 1 })
            .expect(200)
            .expect({ ok: true });
    });

    test("returns 400 for empty object body", async () => {
        await request(app)
            .post("/validate")
            .set("Content-Type", "application/json")
            .send({})
            .expect(400)
            .expect((r) => {
                expect(r.body).toEqual({ error: "Request body is required" });
            });
    });
});
