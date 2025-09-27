import { Router } from "websocket-express";
import prisma from "../utils/prisma.client";
import bcrypt from "bcryptjs";
import {
    validateJSONRequest,
    checkRequiredFields,
    isValidEmail,
    isEmpty
} from "../utils/request.validation";

const router = new Router();
const requiredFields = ["email", "password", "username"];

router.post("/", async (req, res) => {
    console.debug("Received registration request");
    // Validate request
    if (
        validateJSONRequest(req, res) ||
        checkRequiredFields(req.body, res, requiredFields)
    )
        return;
    const { email, password, username } = req.body;
    try {
        // Empty strings check
        if (isEmpty(email, password, username)) {
            console.warn("Empty field(s) detected");
            return res
                .status(400)
                .send({ message: "All fields must contain non-empty values" });
        }
        // Email format validation
        if (!isValidEmail(email)) {
            console.warn("Invalid email format:", email);
            return res.status(400).send({ message: "Invalid email format" });
        }
        /* c8 ignore start */
        // Check if email is already taken
        if (await isEmailTaken(email)) {
            console.warn("Email already registered:", email);
            return res.status(409).send({ message: "Email is already taken" });
        }
        // Create user in the database
        const user = createUser(email, password, username);
        res.status(201).send({ message: "User registered successfully", user });
        /* c8 ignore stop */
    } catch (error) {
        console.error("Error registering user:", error);
        res.status(500).send({ message: "Internal server error" });
    }
});

/* c8 ignore start */
// Create user and return user data without password hash
async function createUser(email: string, password: string, username: string) {
    const { password_hash, ...safeUser } = await prisma.user.create({
        data: {
            email,
            password_hash: await bcrypt.hash(password, 10),
            username
        }
    });
    return safeUser;
}

// Verify if email is already registered
async function isEmailTaken(email: string): Promise<boolean> {
    const user = await prisma.user.findUnique({ where: { email } });
    return user !== null;
}
/* c8 ignore stop */

export default router;
