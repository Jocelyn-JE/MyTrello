import { Router } from "websocket-express";
import {
    validateJSONRequest,
    checkExactFields,
    isEmpty
} from "../utils/request.validation";
import prisma from "../utils/prisma.client";
import { Board, User } from "@prisma/client";
import { verifyToken } from "../utils/jwt";

const router = new Router();
const requiredFields = ["title", "users"];

type UserRole = "member" | "viewer";
type BoardUser = { id: string; role: UserRole };

function isBoardUser(user: unknown): user is BoardUser {
    return (
        typeof user === "object" &&
        user !== null &&
        "id" in user &&
        "role" in user &&
        typeof (user as any).id === "string" &&
        ((user as any).role === "member" || (user as any).role === "viewer")
    );
}

router.post("/", verifyToken, async (req, res) => {
    console.debug("/api/boards: Received create board request");
    if (
        validateJSONRequest(req, res) ||
        checkExactFields(req.body, res, requiredFields)
    )
        return;
    console.debug("Request body validated successfully");
    if (!req.userId) {
        console.error("User ID missing in request after token verification");
        return res.status(500).send({ error: "Internal server error" });
    }
    const { title, users } = req.body;
    const ownerId = req.userId;
    try {
        if (isEmpty(title)) {
            console.warn("Empty title detected");
            return res
                .status(400)
                .send({ error: "Title must contain a non-empty value" });
        }
        if (!Array.isArray(users)) {
            console.warn("Invalid users format:", users);
            return res.status(400).send({ error: "Users must be an array" });
        }
        for (const user of users) {
            if (!isBoardUser(user)) {
                console.warn("Invalid user object:", user);
                return res
                    .status(400)
                    .send({ error: "Invalid user object in users array" });
            }
        }
        const nonExistentUsers = await getNonExistentUsers(users);
        if (nonExistentUsers.length > 0) {
            console.warn("One or more users do not exist:", nonExistentUsers);
            return res.status(400).send({
                error: `One or more users do not exist: ${nonExistentUsers.join(", ")}`
            });
        }
        const board = await createBoard(ownerId, title, users);
        console.info("Board created with title:", title);
        return res
            .status(201)
            .send({ message: "Board created successfully", board });
    } catch (error: unknown) {
        const errorMessage =
            error instanceof Error ? error.message : "Unknown error occurred";
        /* c8 ignore stop */
        console.error("Error creating board:", errorMessage);
        res.status(500).send({ error: "Internal server error" });
    }
});

async function getNonExistentUsers(users: BoardUser[]): Promise<string[]> {
    const userIds = users.map((user) => user.id);
    const foundUsers = await prisma.user.findMany({
        where: { id: { in: userIds } }
    });
    const foundUserIds = foundUsers.map((user) => user.id);
    const nonExistentUserIds = userIds.filter(
        (id) => !foundUserIds.includes(id)
    );
    if (nonExistentUserIds.length > 0) {
        console.warn(`Users not found: ${nonExistentUserIds.join(", ")}`);
    }
    return nonExistentUserIds;
}

async function createBoard(
    ownerId: string,
    title: string,
    users: BoardUser[]
): Promise<Board> {
    const memberIds = users
        .filter((user) => user.role === "member")
        .map((user) => user.id);

    const viewerIds = users
        .filter((user) => user.role === "viewer")
        .map((user) => user.id);

    // Only query if there are IDs to find
    const members: User[] =
        memberIds.length > 0
            ? await prisma.user.findMany({
                  where: { id: { in: memberIds } }
              })
            : [];

    const viewers: User[] =
        viewerIds.length > 0
            ? await prisma.user.findMany({
                  where: { id: { in: viewerIds } }
              })
            : [];

    return prisma.board.create({
        data: {
            title,
            owner: { connect: { id: ownerId } },
            members: { connect: members.map((user) => ({ id: user.id })) },
            viewers: { connect: viewers.map((user) => ({ id: user.id })) }
        },
        include: {
            owner: { select: { id: true, username: true } },
            members: { select: { id: true, username: true } },
            viewers: { select: { id: true, username: true } }
        }
    });
}

router.get("/", verifyToken, async (req, res) => {
    console.debug("/api/boards: Received get boards request");
    if (!req.userId) {
        console.error("User ID missing in request after token verification");
        return res.status(500).send({ error: "Internal server error" });
    }
    const userId = req.userId;
    try {
        const boards = await prisma.board.findMany({
            where: {
                OR: [
                    { ownerId: userId },
                    { members: { some: { id: userId } } },
                    { viewers: { some: { id: userId } } }
                ]
            },
            include: {
                owner: { select: { id: true, username: true } },
                members: { select: { id: true, username: true } },
                viewers: { select: { id: true, username: true } }
            }
        });
        console.info(`Retrieved ${boards.length} boards for user ${userId}`);
        return res
            .status(200)
            .send({ message: "Boards retrieved successfully", boards });
    } catch (error: unknown) {
        const errorMessage =
            error instanceof Error ? error.message : "Unknown error occurred";
        /* c8 ignore stop */
        console.error("Error retrieving boards:", errorMessage);
        res.status(500).send({ error: "Internal server error" });
    }
});

router.delete("/:boardId", verifyToken, async (req, res) => {
    console.debug("/api/boards/:boardId: Received delete board request");
    if (!req.userId) {
        console.error("User ID missing in request after token verification");
        return res.status(500).send({ error: "Internal server error" });
    }
    const userId = req.userId;
    const { boardId } = req.params;
    try {
        const board = await prisma.board.findUnique({
            where: { id: boardId }
        });
        if (!board) {
            console.warn(`Board with ID ${boardId} not found`);
            return res.status(404).send({ error: "Board not found" });
        }
        if (board.ownerId !== userId) {
            console.warn(
                `User ${userId} unauthorized to delete board ${boardId}`
            );
            return res
                .status(403)
                .send({ error: "You are not authorized to delete this board" });
        }
        await prisma.board.delete({
            where: { id: boardId }
        });
        console.info(`Board with ID ${boardId} deleted by user ${userId}`);
        return res.status(200).send({ message: "Board deleted successfully" });
    } catch (error: unknown) {
        const errorMessage =
            error instanceof Error ? error.message : "Unknown error occurred";
        /* c8 ignore stop */
        console.error("Error deleting board:", errorMessage);
        res.status(500).send({ error: "Internal server error" });
    }
});

export default router;
