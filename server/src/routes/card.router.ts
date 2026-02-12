import { Router } from "websocket-express";
import prisma from "../utils/prisma.client";
import { verifyToken } from "../utils/jwt";

const router = new Router();

// GET /api/cards/assigned - Get assigned cards for user
router.get("/assigned", verifyToken, async (req, res) => {
    console.debug("/api/cards/assigned: Fetching assigned cards for user");
    if (!req.userId) {
        console.error("User ID missing in request after token verification");
        return res.status(500).send({ error: "Internal server error" });
    }
    const userId = req.userId;

    try {
        const cards = await prisma.card.findMany({
            where: {
                assignees: { some: { id: userId } }
            },
            select: {
                id: true,
                title: true,
                content: true,
                startDate: true,
                dueDate: true,
                createdAt: true,
                updatedAt: true,
                column: {
                    select: {
                        id: true,
                        title: true,
                        board: {
                            select: {
                                id: true,
                                title: true
                            }
                        }
                    }
                }
            },
            orderBy: [{ dueDate: "asc" }, { createdAt: "desc" }]
        });

        // Transform the response to flatten board info
        const transformedCards = cards.map((card) => ({
            id: card.id,
            title: card.title,
            content: card.content,
            startDate: card.startDate,
            dueDate: card.dueDate,
            columnId: card.column.id,
            columnTitle: card.column.title,
            boardId: card.column.board.id,
            boardTitle: card.column.board.title,
            createdAt: card.createdAt,
            updatedAt: card.updatedAt
        }));

        console.info(
            `Retrieved ${transformedCards.length} assigned cards for user ${userId}`
        );
        return res.status(200).send({
            message: "Assigned cards retrieved successfully",
            cards: transformedCards
        });
    } catch (error: unknown) {
        const errorMessage =
            error instanceof Error ? error.message : "Unknown error occurred";
        console.error("Error retrieving assigned cards:", errorMessage);
        res.status(500).send({ error: "Internal server error" });
    }
});

export default router;
