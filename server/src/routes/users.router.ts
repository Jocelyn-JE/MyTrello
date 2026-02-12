import { Router } from "websocket-express";
import prisma from "../utils/prisma.client";
import { verifyToken } from "../utils/jwt";
import { isUserPartOfBoard } from "../utils/board_access";

const router = new Router();

// GET /api/users - Get all users
router.get("/", verifyToken, async (req, res) => {
    console.debug("/api/users: Fetching all users");
    if (!req.userId) {
        console.error("User ID missing in request after token verification");
        return res.status(500).send({ error: "Internal server error" });
    }
    try {
        const users = await prisma.user.findMany({
            where: { username: { contains: "", mode: "insensitive" } },
            take: 100,
            orderBy: { username: "asc" },
            omit: { password_hash: true }
        });
        res.status(200).json(users);
    } catch (error) {
        console.error("Error fetching users:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

// GET /api/users/:boardId/members - Get board members
router.get("/:boardId/members", verifyToken, async (req, res) => {
    const { boardId } = req.params;
    console.debug(
        `/api/users/${boardId}/members: Fetching members for board ${boardId}`
    );
    if (!req.userId) {
        console.error("User ID missing in request after token verification");
        return res.status(500).send({ error: "Internal server error" });
    }
    const userId = req.userId;
    try {
        // Check if user has access to this board
        const hasAccess = await isUserPartOfBoard(userId, boardId);
        if (!hasAccess) {
            console.warn(
                `User ${userId} attempted to access members of board ${boardId} without permission`
            );
            return res
                .status(403)
                .json({ error: "Access denied to this board" });
        }
        const users = await prisma.user.findMany({
            where: {
                member_boards: { some: { id: boardId } }
            },
            orderBy: { username: "asc" },
            omit: { password_hash: true }
        });
        res.status(200).json(users);
    } catch (error) {
        console.error(`Error fetching users for board ${boardId}:`, error);
        res.status(500).json({ error: "Internal server error" });
    }
});

// GET /api/users/:boardId/viewers - Get board viewers
router.get("/:boardId/viewers", verifyToken, async (req, res) => {
    const { boardId } = req.params;
    console.debug(
        `/api/users/${boardId}/viewers: Fetching viewers for board ${boardId}`
    );
    if (!req.userId) {
        console.error("User ID missing in request after token verification");
        return res.status(500).send({ error: "Internal server error" });
    }
    const userId = req.userId;
    try {
        // Check if user has access to this board
        const hasAccess = await isUserPartOfBoard(userId, boardId);
        if (!hasAccess) {
            console.warn(
                `User ${userId} attempted to access viewers of board ${boardId} without permission`
            );
            return res
                .status(403)
                .json({ error: "Access denied to this board" });
        }
        const users = await prisma.user.findMany({
            where: {
                viewed_boards: { some: { id: boardId } }
            },
            orderBy: { username: "asc" },
            omit: { password_hash: true }
        });
        res.status(200).json(users);
    } catch (error) {
        console.error(`Error fetching users for board ${boardId}:`, error);
        res.status(500).json({ error: "Internal server error" });
    }
});

const filters = ["username", "email"];

type QueryValues = {
    username?: string;
    email?: string;
    order?: "asc" | "desc";
    count?: number;
    boardId?: string;
    member?: boolean;
    viewer?: boolean;
    cardId?: string;
    assigned?: boolean;
};

// GET /api/users/search - Search users with filters
router.get("/search", verifyToken, async (req, res) => {
    console.debug("/api/users/search: Searching users with filters");
    if (!req.userId) {
        console.error("User ID missing in request after token verification");
        return res.status(500).send({ error: "Internal server error" });
    }
    const userId = req.userId;
    try {
        const query: any = req.query;
        const validationError = validateQueryParams(query);
        if (validationError)
            return res.status(400).json({ error: validationError });

        const queryFilters: QueryValues = {};
        filters.forEach((filter) => {
            if (query[filter])
                queryFilters[filter as keyof QueryValues] = query[filter];
        });
        if (query.order) queryFilters.order = query.order;
        if (query.count) queryFilters.count = parseInt(query.count, 10);
        if (query.boardId) queryFilters.boardId = query.boardId;
        if (query.member) queryFilters.member = query.member === "true";
        if (query.viewer) queryFilters.viewer = query.viewer === "true";
        if (query.cardId) queryFilters.cardId = query.cardId;
        if (query.assigned) queryFilters.assigned = query.assigned === "true";

        // Check board access if boardId is provided
        if (queryFilters.boardId) {
            const hasAccess = await isUserPartOfBoard(
                userId,
                queryFilters.boardId
            );
            if (!hasAccess) {
                console.warn(
                    `User ${userId} attempted to search users for board ${queryFilters.boardId} without permission`
                );
                return res
                    .status(403)
                    .json({ error: "Access denied to this board" });
            }
        }

        const where: any = {};
        if (queryFilters.username)
            where.username = {
                startsWith: queryFilters.username,
                mode: "insensitive"
            };
        if (queryFilters.email)
            where.email = {
                startsWith: queryFilters.email,
                mode: "insensitive"
            };

        // Handle board filtering
        if (queryFilters.member || queryFilters.viewer) {
            const boardConditions: any[] = [];

            if (queryFilters.member) {
                // Include both members and owners when searching for members
                const memberConditions = [
                    {
                        member_boards: queryFilters.boardId
                            ? { some: { id: queryFilters.boardId } }
                            : { some: {} }
                    },
                    {
                        owned_boards: queryFilters.boardId
                            ? { some: { id: queryFilters.boardId } }
                            : { some: {} }
                    }
                ];
                boardConditions.push(...memberConditions);
            }

            if (queryFilters.viewer) {
                boardConditions.push({
                    viewed_boards: queryFilters.boardId
                        ? { some: { id: queryFilters.boardId } }
                        : { some: {} }
                });
            }

            // Use OR logic to combine all conditions
            if (boardConditions.length > 1) {
                where.OR = boardConditions;
            } else {
                Object.assign(where, boardConditions[0]);
            }
        } else if (queryFilters.boardId) {
            // If only boardId is provided without member/viewer flags, search owners, members, and viewers
            where.OR = [
                { owned_boards: { some: { id: queryFilters.boardId } } },
                { member_boards: { some: { id: queryFilters.boardId } } },
                { viewed_boards: { some: { id: queryFilters.boardId } } }
            ];
        }

        // Handle card assignment filtering
        if (queryFilters.cardId !== undefined) {
            if (queryFilters.assigned === false) {
                // Filter users NOT assigned to the card
                where.NOT = {
                    assigned_cards: { some: { id: queryFilters.cardId } }
                };
            } else {
                // Filter users assigned to the card (default if assigned is true or not specified)
                where.assigned_cards = { some: { id: queryFilters.cardId } };
            }
        }

        const orderBy: any = {};
        if (queryFilters.order && queryFilters.username)
            orderBy.username = queryFilters.order;
        if (queryFilters.order && queryFilters.email)
            orderBy.email = queryFilters.order;
        const take = queryFilters.count || undefined;

        console.debug(
            "Search parameters:",
            JSON.stringify({ where, orderBy, take }, null, 2)
        );
        const users = await prisma.user.findMany({
            where,
            orderBy,
            take,
            omit: { password_hash: true }
        });
        res.status(200).json(users);
    } catch (error) {
        console.error("Error searching users:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

function isPositiveInteger(value: string): boolean {
    const num = Number(value);
    return Number.isInteger(num) && num > 0;
}

function isValidOrder(value: string): boolean {
    return value === "asc" || value === "desc";
}

function validateQueryParams(query: any): string | null {
    if (query.count && !isPositiveInteger(query.count))
        return "Count must be a positive integer";
    if (query.order && !isValidOrder(query.order))
        return 'Order must be either "asc" or "desc"';
    return null;
}

export default router;
