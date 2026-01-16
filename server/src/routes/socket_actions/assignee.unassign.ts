import { SocketAction } from "./action_type";
import prisma from "../../utils/prisma.client";

type AssigneeUnassignData = {
    cardId: string;
    userId: string;
};

export const assigneeUnassignAction: SocketAction = {
    actionName: "assignee.unassign",
    async execute(boardId: string, listData: AssigneeUnassignData, _userId: string) {
        console.info(
            `Unassigning user ${listData.userId} from card ${listData.cardId} in board ${boardId}`
        );
        const assignee = await prisma.user.update({
            where: { id: listData.userId },
            data: {
                assigned_cards: {
                    disconnect: { id: listData.cardId }
                }
            }
        });
        console.info(`User unassigned: ${assignee.id}`);
        return { userId: assignee.id, cardId: listData.cardId };
    }
};
