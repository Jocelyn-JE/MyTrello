import { SocketAction } from "./action_type";
import prisma from "../../utils/prisma.client";
import { cardExists } from "../room_utils/get_card";
import { tagExists } from "../room_utils/get_tag";
import { moveCardAtIndex } from "../room_utils/move_card_at_index";

type CardUpdateData = {
    id: string;
    columnId?: string;
    index?: number;
    tagId?: string | null;
    title?: string;
    content?: string;
    startDate?: Date | null;
    dueDate?: Date | null;
};

export const cardUpdateAction: SocketAction = {
    actionName: "card.update",
    async execute(boardId: string, cardData: CardUpdateData) {
        console.info(
            `Updating card with ID "${cardData.id}" to "${cardData}" in board ${boardId}`
        );
        if (cardData.title !== undefined && cardData.title.trim() === "") {
            console.error("Card title cannot be empty");
            throw new Error("Card title cannot be empty");
        }
        if (cardData.content !== undefined && cardData.content.trim() === "") {
            console.error("Card content cannot be empty");
            throw new Error("Card content cannot be empty");
        }
        if (!(await cardExists(cardData.id))) {
            console.error(`Card with ID ${cardData.id} does not exist`);
            throw new Error("Card does not exist");
        }
        if (
            cardData.tagId !== undefined &&
            cardData.tagId &&
            !(await tagExists(cardData.tagId))
        ) {
            console.error(`Tag with ID ${cardData.tagId} does not exist`);
            throw new Error("Tag does not exist");
        }
        // Build update object with only provided fields
        const updateData: any = {
            updatedAt: new Date()
        };

        if (cardData.columnId !== undefined || cardData.index !== undefined)
            await moveCardAtIndex(
                cardData.columnId,
                cardData.index,
                cardData.id
            );
        if (cardData.tagId !== undefined) updateData.tagId = cardData.tagId;
        if (cardData.title !== undefined) updateData.title = cardData.title;
        if (cardData.content !== undefined)
            updateData.content = cardData.content;
        if (cardData.startDate !== undefined)
            updateData.startDate = cardData.startDate;
        if (cardData.dueDate !== undefined)
            updateData.dueDate = cardData.dueDate;
        const card = await prisma.card.update({
            where: {
                id: cardData.id
            },
            data: updateData
        });
        console.info(`Card updated with ID: ${card.id}`);
        return card;
    }
};
