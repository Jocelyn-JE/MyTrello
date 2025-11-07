import { SocketAction } from "./action_type";
import prisma from "../../utils/prisma.client";

type CardCreateData = {
    title: string;
    columnId: string;
    content: string;
    startDate: Date | null;
    dueDate: Date | null;
    tagId: string | null;
};

export const cardCreationAction: SocketAction = {
    actionName: "card.create",
    async execute(boardId: string, cardData: CardCreateData) {
        console.info(
            `Creating card with title "${cardData.title}" in board ${boardId}`
        );
        const card = await prisma.card.create({
            data: {
                title: cardData.title,
                columnId: cardData.columnId,
                content: cardData.content,
                index: await prisma.card.count({
                    where: { columnId: cardData.columnId }
                }),
                createdAt: new Date(),
                updatedAt: new Date(),
                startDate: cardData.startDate,
                dueDate: cardData.dueDate,
                tagId: cardData.tagId
            }
        });
        console.info(`Card created with ID: ${card.id}`);
        return card;
    }
};
