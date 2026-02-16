import { Router } from "websocket-express";
import prisma from "../utils/prisma.client";
import { verifyToken } from "../utils/jwt";
import {
    validateJSONRequest,
} from "../utils/request.validation";

const router = new Router();

// GET /api/preferences - Get user preferences
router.get("/", verifyToken, async (req, res) => {
    console.debug("/api/preferences: Fetching user preferences");
    if (!req.userId) {
        console.error("User ID missing in request after token verification");
        return res.status(500).send({ error: "Internal server error" });
    }
    try {
        const settings = await prisma.userSettings.findUnique({
            where: { userId: req.userId }
        });
        if (!settings) {
            console.warn(`No preferences found for user ${req.userId}`);
            return res.status(404).send({ error: "Preferences not found" });
        }
        res.status(200).json(settings);
    } catch (error) {
        console.error("Error fetching user preferences:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

// PATCH /api/preferences - Update user preferences
router.patch("/", verifyToken, async (req, res) => {
    console.debug("/api/preferences: Updating user preferences");
    if (!req.userId) {
        console.error("User ID missing in request after token verification");
        return res.status(500).send({ error: "Internal server error" });
    }
    if (validateJSONRequest(req, res)) return;

    const { localization, theme, showAssignedCardsInHomepage } = req.body;

    // Validate at least one field is provided
    if (
        localization === undefined &&
        theme === undefined &&
        showAssignedCardsInHomepage === undefined
    ) {
        console.warn("No valid fields provided for update");
        return res
            .status(400)
            .send({ error: "At least one field must be provided" });
    }

    // Build update data object with only provided fields
    const updateData: {
        localization?: string;
        theme?: string;
        showAssignedCardsInHomepage?: boolean;
    } = {};

    if (localization !== undefined) {
        if (typeof localization !== "string" || localization.trim() === "") {
            return res
                .status(400)
                .send({ error: "Invalid localization format" });
        }
        updateData.localization = localization;
    }

    if (theme !== undefined) {
        if (!["dark", "light", "system"].includes(theme)) {
            return res.status(400).send({
                error: "Invalid theme. Must be 'dark', 'light', or 'system'"
            });
        }
        updateData.theme = theme;
    }

    if (showAssignedCardsInHomepage !== undefined) {
        if (typeof showAssignedCardsInHomepage !== "boolean") {
            return res
                .status(400)
                .send({ error: "showAssignedCardsInHomepage must be a boolean" });
        }
        updateData.showAssignedCardsInHomepage = showAssignedCardsInHomepage;
    }

    try {
        const updatedSettings = await prisma.userSettings.update({
            where: { userId: req.userId },
            data: updateData
        });
        res.status(200).json(updatedSettings);
    } catch (error) {
        console.error("Error updating user preferences:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

export default router;
