import { SocketAction } from "./action_type";
import prisma from "../../utils/prisma.client";

export const chatSendAction: SocketAction = {
    actionName: "chat.send",
    async execute(boardId: string, data: string, userId: string) {
        console.info(
            `Message "${data}" sent in board ${boardId} by user ${userId}`
        );
        const message = await prisma.message.create({
            data: {
                boardId: boardId,
                userId: userId,
                content: data
            }
        });
        if (!message) {
            console.error("Failed to create message");
            throw new Error("Failed to create message");
        }
        const sender = await prisma.user.findUnique({
            where: { id: userId },
            select: {
                id: true,
                username: true,
                email: true,
                createdAt: true,
                updatedAt: true
            }
        });
        if (!sender) {
            console.error("Failed to fetch sender info");
            throw new Error("Failed to fetch sender info");
        }
        console.info(`Message created with ID: ${message.id}`);
        return {
            id: message.id,
            content: message.content,
            createdAt: message.createdAt,
            user: sender
        };
    }
};
