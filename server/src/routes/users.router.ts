import { Router } from "websocket-express";
import prisma from "../utils/prisma.client";

const router = new Router();

router.get("/", async (req, res) => {
    console.debug("/api/users: Fetching all users");
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

router.get("/:boardId/members", async (req, res) => {
    const { boardId } = req.params;
    console.debug(
        `/api/users/${boardId}/members: Fetching members for board ${boardId}`
    );
    try {
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

router.get("/:boardId/viewers", async (req, res) => {
    const { boardId } = req.params;
    console.debug(
        `/api/users/${boardId}/viewers: Fetching viewers for board ${boardId}`
    );
    try {
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
};

router.get("/search", async (req, res) => {
    console.debug("/api/users/search: Searching users with filters");
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
                boardConditions.push({
                    member_boards: queryFilters.boardId
                        ? { some: { id: queryFilters.boardId } }
                        : { some: {} }
                });
            }
            
            if (queryFilters.viewer) {
                boardConditions.push({
                    viewed_boards: queryFilters.boardId
                        ? { some: { id: queryFilters.boardId } }
                        : { some: {} }
                });
            }
            
            // If both member and viewer are true, use OR logic
            if (boardConditions.length > 1) {
                where.OR = boardConditions;
            } else {
                Object.assign(where, boardConditions[0]);
            }
        } else if (queryFilters.boardId) {
            // If only boardId is provided without member/viewer flags, search both
            where.OR = [
                { member_boards: { some: { id: queryFilters.boardId } } },
                { viewed_boards: { some: { id: queryFilters.boardId } } }
            ];
        }
        const orderBy: any = {};
        if (queryFilters.order && queryFilters.username)
            orderBy.username = queryFilters.order;
        if (queryFilters.order && queryFilters.email)
            orderBy.email = queryFilters.order;
        const take = queryFilters.count || undefined;

        console.debug("Search parameters:", { where, orderBy, take });
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
