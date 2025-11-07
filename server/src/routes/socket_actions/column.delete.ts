import { SocketAction } from "./action_type";
import prisma from "../../utils/prisma.client";

type ColumnDeleteData = {
    id: string;
};

export const columnDeletionAction: SocketAction = {
    actionName: "column.delete",
    async execute(boardId: string, columnData: ColumnDeleteData) {
        console.info(
            `Deleting column with ID "${columnData.id}" from board ${boardId}`
        );
        const column = await prisma.column.delete({
            where: {
                id: columnData.id
            }
        });
        console.info(`Column deleted with ID: ${column.id}`);
        return column;
    }
};
