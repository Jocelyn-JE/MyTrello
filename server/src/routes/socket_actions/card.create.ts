import { SocketAction } from "./action_type";
import prisma from "../../utils/prisma.client";
import { userExists } from "../room_utils/get_user";
import { columnExists } from "../room_utils/get_column";
import { tagExists } from "../room_utils/get_tag";

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
        if (!cardData.title || cardData.title.trim() === "") {
            console.error("Card title cannot be empty");
            throw new Error("Card title cannot be empty");
        }
        if (!cardData.content || cardData.content.trim() === "") {
            console.error("Card content cannot be empty");
            throw new Error("Card content cannot be empty");
        }
        if (!(await columnExists(cardData.columnId))) {
            console.error(`Column with ID ${cardData.columnId} does not exist`);
            throw new Error("Column does not exist");
        }
        if (cardData.tagId && !(await tagExists(cardData.tagId))) {
            console.error(`Tag with ID ${cardData.tagId} does not exist`);
            throw new Error("Tag does not exist");
        }
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
