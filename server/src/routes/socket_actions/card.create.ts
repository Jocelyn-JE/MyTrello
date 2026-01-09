import { SocketAction } from "./action_type";
import prisma from "../../utils/prisma.client";
import { columnExists } from "../room_utils/get_column";
import { tagExists } from "../room_utils/get_tag";
import { getNextCardIndex } from "../room_utils/get_next_card_index";

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
        const card = await prisma.card.create({
            data: {
                title: cardData.title,
                columnId: cardData.columnId,
                content: cardData.content,
                index: await getNextCardIndex(cardData.columnId),
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
