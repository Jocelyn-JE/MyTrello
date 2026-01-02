import { SocketAction } from "./action_type";
import prisma from "../../utils/prisma.client";

type AssigneeListData = {
    cardId: string;
};

export const assigneeListingAction: SocketAction = {
    actionName: "assignee.list",
    async execute(boardId: string, listData: AssigneeListData) {
        console.info(
            `Listing assignees of card ${listData.cardId} in board ${boardId}`
        );
        const assignees = await prisma.user.findMany({
            where: { assigned_cards: { some: { id: listData.cardId } } },
            orderBy: { username: "asc" }
        });
        console.info(`Assignees found: ${assignees.length}`);
        return assignees;
    }
};
