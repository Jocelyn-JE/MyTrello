import { SocketAction } from "./action_type";
import prisma from "../../utils/prisma.client";

type AssigneeAssignData = {
    cardId: string;
    userId: string;
};

export const assigneeAssignAction: SocketAction = {
    actionName: "assignee.assign",
    async execute(boardId: string, listData: AssigneeAssignData, _userId: string) {
        console.info(
            `Assigning user ${listData.userId} to card ${listData.cardId} in board ${boardId}`
        );
        const assignee = await prisma.user.update({
            where: { id: listData.userId },
            data: {
                assigned_cards: {
                    connect: { id: listData.cardId }
                }
            }
        });
        console.info(`User assigned: ${assignee.id}`);
        return { user: assignee, cardId: listData.cardId };
    }
};
