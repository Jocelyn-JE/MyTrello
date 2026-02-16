import { Router } from "websocket-express";
import prisma from "../utils/prisma.client";
import bcrypt from "bcryptjs";
import {
    validateJSONRequest,
    checkExactFields,
    isEmpty
} from "../utils/request.validation";
import { isValidEmail } from "../utils/regex";

const router = new Router();
const requiredFields = ["email", "password", "username"];

// POST /api/register - Register new user
router.post("/", async (req, res) => {
    console.debug("/api/register: Received registration request");
    // Validate request
    if (
        validateJSONRequest(req, res) ||
        checkExactFields(req.body, res, requiredFields)
    )
        return;
    const { email, password, username } = req.body;
    try {
        // Empty strings check
        if (isEmpty(email, password, username)) {
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
        /* c8 ignore start */
        // Check if email is already taken
        if (await isEmailTaken(email)) {
            console.warn("Email already registered:", email);
            return res.status(409).send({ error: "Email is already taken" });
        }
        // Create user in the database
        const user = await createUser(email, password, username);
        res.status(201).send({ message: "User registered successfully", user });
    } catch (error: unknown) {
        const errorMessage =
            error instanceof Error ? error.message : "Unknown error occurred";
        /* c8 ignore stop */
        console.error("Error registering user:", errorMessage);
        res.status(500).send({ error: "Internal server error" });
    }
});

/* c8 ignore start */
// Create user and return user data without password hash
async function createUser(email: string, password: string, username: string) {
    const { password_hash: _password_hash, ...safeUser } =
        await prisma.user.create({
            data: {
                email,
                password_hash: await bcrypt.hash(password, 10),
                username,
                settings: {
                    create: {
                        localization: "en/US",
                        theme: "system",
                        showAssignedCardsInHomepage: true
                    }
                }
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
