import { SocketAction } from "./action_type";
import prisma from "../../utils/prisma.client";

type CardListData = {
    columnId: string;
};

export const cardListingAction: SocketAction = {
    actionName: "card.list",
    async execute(boardId: string, listData: CardListData) {
        console.info(
            `Listing cards in column ${listData.columnId} of board ${boardId}`
        );
        const columns = await prisma.card.findMany({
            where: { columnId: listData.columnId },
            orderBy: { index: "asc" }
        });
        console.info(`Cards found: ${columns.length}`);
        return columns;
    }
};
