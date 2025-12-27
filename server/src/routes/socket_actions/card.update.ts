import { SocketAction } from "./action_type";
import prisma from "../../utils/prisma.client";
import { cardExists, getCardInfo } from "../room_utils/get_card";
import { tagExists } from "../room_utils/get_tag";
import { userExists } from "../room_utils/get_user";

type CardUpdateData = {
    id: string;
    columnId?: string;
    index?: number;
    tagId?: string | null;
    title?: string;
    content?: string;
    startDate?: Date | null;
    dueDate?: Date | null;
    assignees?: string[] | null;
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
        if (
            cardData.assignees !== undefined &&
            cardData.assignees &&
            cardData.assignees.some(async (id) => !(await userExists(id)))
        ) {
            console.error(
                `One or more assignees do not exist: ${cardData.assignees}`
            );
            throw new Error("One or more assignees do not exist");
        }
        // Build update object with only provided fields
        const updateData: any = {
            updatedAt: new Date()
        };

        // If columnId is changing but index is not provided, find next available index
        if (cardData.columnId !== undefined && cardData.index === undefined) {
            const currentCard = await getCardInfo(cardData.id);
            
            // Only auto-assign index if moving to a different column
            if (currentCard && currentCard.columnId !== cardData.columnId) {
                const maxIndexCard = await prisma.card.findFirst({
                    where: { columnId: cardData.columnId },
                    orderBy: { index: 'desc' },
                    select: { index: true }
                });
                updateData.index = maxIndexCard ? maxIndexCard.index + 1 : 0;
            }
        }

        if (cardData.columnId !== undefined)
            updateData.columnId = cardData.columnId;
        if (cardData.index !== undefined) updateData.index = cardData.index;
        if (cardData.tagId !== undefined) updateData.tagId = cardData.tagId;
        if (cardData.title !== undefined) updateData.title = cardData.title;
        if (cardData.content !== undefined)
            updateData.content = cardData.content;
        if (cardData.startDate !== undefined)
            updateData.startDate = cardData.startDate;
        if (cardData.dueDate !== undefined)
            updateData.dueDate = cardData.dueDate;
        if (cardData.assignees !== undefined) {
            updateData.assignees = {
                set: cardData.assignees
                    ? cardData.assignees.map((id) => ({ id }))
                    : []
            };
        }

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
