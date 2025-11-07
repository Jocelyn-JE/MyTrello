import { SocketAction } from "./action_type";
import prisma from "../../utils/prisma.client";

type ColumnRenameData = {
    id: string;
    title: string;
};

export const columnRenameAction: SocketAction = {
    actionName: "column.rename",
    async execute(boardId: string, columnData: ColumnRenameData) {
        console.info(
            `Renaming column with ID "${columnData.id}" to "${columnData.title}" in board ${boardId}`
        );
        const column = await prisma.column.update({
            where: {
                id: columnData.id
            },
            data: {
                title: columnData.title,
                updatedAt: new Date()
            }
        });
        console.info(`Column renamed with ID: ${column.id}`);
        return column;
    }
};
