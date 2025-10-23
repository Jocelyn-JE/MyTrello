import jwt from "jsonwebtoken";
import { Request, Response, NextFunction } from "express";

const JWT_SECRET = process.env.JWT_SECRET || "your_jwt_secret";
const JWT_EXPIRES_IN = 3600000; // Token expiration time in ms

declare global {
    namespace Express {
        interface Request {
            userId?: string;
        }
    }
}

export type JwtPayload = {
    userId: string;
    expiresAt: number;
};

// Function to generate a JWT for a given user ID
export function generateToken(userId: string): string {
    const payload: JwtPayload = {
        userId,
        expiresAt: Date.now() + JWT_EXPIRES_IN
    };
    return jwt.sign(payload, JWT_SECRET);
}

export async function getTokenPayload(token: string): Promise<JwtPayload> {
    return new Promise((resolve, reject) => {
        jwt.verify(token, JWT_SECRET, (err, decoded) => {
            if (err) {
                console.error("JWT verification failed:", err.message);
                return reject(new Error("Invalid token"));
            }
            const payload = decoded as JwtPayload;
            if (payload.expiresAt < Date.now()) {
                console.warn("JWT has expired");
                return reject(new Error("Token has expired"));
            }
            resolve(payload);
        });
    });
}

// Middleware to verify JWT and attach user info to the request
export async function verifyToken(
    req: Request,
    res: Response,
    next: NextFunction
) {
    console.debug("Verifying JWT for incoming request");
    if (!req.headers || !req.headers.authorization) {
        console.warn("No authorization header present");
        return res.status(401).send({ error: "No token provided" });
    }
    const authHeader = req.headers.authorization;
    if (!authHeader)
        return res.status(401).send({ error: "No token provided" });
    const token = authHeader.split(" ")[1]; // Bearer <token>
    if (!token) return res.status(401).send({ error: "No token provided" });
    try {
        const decoded = jwt.verify(token, JWT_SECRET);
        const { userId, expiresAt } = decoded as JwtPayload;
        if (expiresAt < Date.now())
            return res.status(401).send({ error: "Token has expired" });
        req.userId = userId;
        next();
    } catch (error: unknown) {
        const errorMessage =
            error instanceof Error ? error.message : "Unknown error occurred";
        console.error("JWT verification error:", errorMessage);
        return res.status(401).send({ error: "Invalid token" });
    }
}
