import { SocketAction } from "./action_type";
import prisma from "../../utils/prisma.client";

export const chatHistoryAction: SocketAction = {
    actionName: "chat.history",
    async execute(boardId: string, data: string, userId: string) {
        console.info(
            `Fetching chat history in board ${boardId} for user ${userId}`
        );
        const messages = await prisma.message.findMany({
            where: { boardId },
            orderBy: { createdAt: "asc" },
            select: {
                id: true,
                createdAt: true,
                content: true,
                user: {
                    select: {
                        id: true,
                        username: true,
                        email: true,
                        createdAt: true,
                        updatedAt: true
                    }
                }
            }
        });
        console.info(`Messages found: ${messages.length}`);
        return messages;
    }
};
