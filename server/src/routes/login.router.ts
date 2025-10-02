import { Router } from "websocket-express";
import prisma from "../utils/prisma.client";
import bcrypt from "bcryptjs";
import {
    validateJSONRequest,
    checkExactFields,
    isEmpty
} from "../utils/request.validation";
import { generateToken } from "../utils/jwt";
import { isValidEmail } from "../utils/regex";

const router = new Router();
const requiredFields = ["email", "password"];

router.post("/", async (req, res) => {
    console.debug("/api/login: Received login request");
    // Validate request
    if (
        validateJSONRequest(req, res) ||
        checkExactFields(req.body, res, requiredFields)
    )
        return;
    const { email, password } = req.body;
    // Empty strings check
    if (isEmpty(email, password)) {
        console.warn("Empty field(s) detected");
        return res
            .status(400)
            .send({ error: "All fields must contain non-empty values" });
    }
    // Email format validation
    if (!isValidEmail(email)) {
        console.warn("Invalid email format:", email);
        return res.status(400).send({ error: "Invalid email format" });
    }

    try {
        // Find user by email
        const user = await prisma.user.findUnique({ where: { email } });
        const passwordMatch = user
            ? await bcrypt.compare(password, user.password_hash)
            : false;
        if (!user || !passwordMatch) {
            if (!user) console.warn("User not found for email:", email);
            else console.warn("Incorrect password for email:", email);
            return res.status(401).send({ error: "Invalid email or password" });
        }
        // Successful login
        const { password_hash: _password_hash, ...safeUser } = user;
        console.info("User logged in:", email);
        res.status(200).send({
            message: "Login successful",
            user: safeUser,
            token: generateToken(user.id)
        });
    } catch (error: unknown) {
        const errorMessage =
            error instanceof Error ? error.message : "Unknown error occurred";
        console.error("Error during login:", errorMessage);
        res.status(500).send({ error: "Internal server error" });
    }
});

export default router;
