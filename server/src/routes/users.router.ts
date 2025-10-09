import { Router } from "websocket-express";
import prisma from "../utils/prisma.client";
import { User } from "@prisma/client";

const router = new Router();

router.get("/", async (req, res) => {
    console.debug("/api/users: Fetching all users");
    try {
        const users: User[] = await prisma.user.findMany({ where: {username: {contains: "", mode: "insensitive"}}, take: 100, orderBy: { username: 'asc' } });
        res.status(200).json(users);
    } catch (error) {
        console.error("Error fetching users:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

const filters = ["username", "email"];

type QueryValues = {
    username?: string;
    email?: string;
    order?: "asc" | "desc";
    count?: number;
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
        if (query.order)
            queryFilters.order = query.order;
        if (query.count)
            queryFilters.count = parseInt(query.count, 10);

        const where: any = {};
        if (queryFilters.username)
            where.username = { startsWith: queryFilters.username, mode: "insensitive" };
        if (queryFilters.email) 
            where.email = { startsWith: queryFilters.email, mode: "insensitive" };
        const orderBy: any = {};
        if (queryFilters.order && queryFilters.username)
            orderBy.username = queryFilters.order;
        if (queryFilters.order && queryFilters.email)
            orderBy.email = queryFilters.order;
        const take = queryFilters.count || undefined;

        console.debug("Search parameters:", { where, orderBy, take });
        const users: User[] = await prisma.user.findMany({ where, orderBy, take });
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
