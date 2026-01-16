import { SocketAction } from "./action_type";
import prisma from "../../utils/prisma.client";

type AssigneeListData = {
    cardId: string;
};

export const assigneeListingAction: SocketAction = {
    actionName: "assignee.list",
    async execute(
        boardId: string,
        listData: AssigneeListData,
        _userId: string
    ) {
        console.info(
            `Listing assignees of card ${listData.cardId} in board ${boardId}`
        );
        const assignees = await prisma.user.findMany({
            where: { assigned_cards: { some: { id: listData.cardId } } },
            orderBy: { username: "asc" },
            select: {
                id: true,
                username: true,
                email: true,
                createdAt: true,
                updatedAt: true
            }
        });
        console.info(`Assignees found: ${assignees.length}`);
        return { cardId: listData.cardId, assignees };
    }
};
