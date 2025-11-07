import { SocketAction } from "./action_type";
import prisma from "../../utils/prisma.client";
import { userExists } from "../room_utils/get_user";

type CardCreateData = {
    title: string;
    columnId: string;
    content: string;
    startDate: Date | null;
    dueDate: Date | null;
    tagId: string | null;
    assignees: string[] | null;
};

export const cardCreationAction: SocketAction = {
    actionName: "card.create",
    async execute(boardId: string, cardData: CardCreateData) {
        console.info(
            `Creating card with title "${cardData.title}" in board ${boardId}`
        );
        if (
            cardData.assignees &&
            cardData.assignees.some(async (id) => !(await userExists(id)))
        ) {
            console.error(
                `One or more assignees do not exist: ${cardData.assignees}`
            );
            throw new Error("One or more assignees do not exist");
        }
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
                tagId: cardData.tagId,
                assignees: {
                    connect: cardData.assignees?.map((assigneeId) => ({
                        id: assigneeId
                    }))
                }
            }
        });
        console.info(`Card created with ID: ${card.id}`);
        return card;
    }
};
