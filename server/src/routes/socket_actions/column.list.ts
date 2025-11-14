import { SocketAction } from "./action_type";
import prisma from "../../utils/prisma.client";

export const columnListingAction: SocketAction = {
    actionName: "column.list",
    async execute(boardId: string, _data: null) {
        console.info(`Listing columns in board ${boardId}`);
        const columns = await prisma.column.findMany({
            where: { boardId },
            orderBy: { index: "asc" }
        });
        console.info(`Columns found: ${columns.length}`);
        return columns;
    }
};
