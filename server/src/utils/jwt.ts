import jwt from "jsonwebtoken";
import { Request, Response, NextFunction } from "express";

const JWT_SECRET = process.env.JWT_SECRET || "your_jwt_secret";
const JWT_EXPIRES_IN = 3600000; // Token expiration time in ms

interface JwtPayload {
    userId: string;
    expiresAt: number;
}

// Function to generate a JWT for a given user ID
export function generateToken(userId: string): string {
    const payload: JwtPayload = {
        userId,
        expiresAt: Date.now() + JWT_EXPIRES_IN
    };
    return jwt.sign(payload, JWT_SECRET);
}

// Middleware to verify JWT and attach user info to the request
export function verifyToken(req: Request, res: Response, next: NextFunction) {
    const authHeader = req.headers.authorization;
    if (!authHeader)
        return res.status(401).send({ message: "No token provided" });
    const token = authHeader.split(" ")[1]; // Bearer <token>
    if (!token) return res.status(401).send({ message: "No token provided" });
    jwt.verify(token, JWT_SECRET, (err: any, decoded: any) => {
        if (err || !decoded || typeof decoded === "string")
            return res.status(401).send({ message: "Invalid token" });
        if ((decoded as JwtPayload).expiresAt < Date.now())
            return res.status(401).send({ message: "Token has expired" });
        // Attach userId to request object for further use
        (req as any).userId = (decoded as JwtPayload).userId;
        next();
    });
}
