import { SocketAction } from "./action_type";
import prisma from "../../utils/prisma.client";
import { columnExists } from "../room_utils/get_column";

type ColumnRenameData = {
    id: string;
    title: string;
};

export const columnRenameAction: SocketAction = {
    actionName: "column.rename",
    async execute(
        boardId: string,
        columnData: ColumnRenameData,
        _userId: string
    ) {
        console.info(
            `Renaming column with ID "${columnData.id}" to "${columnData.title}" in board ${boardId}`
        );
        if (!columnData.title || columnData.title.trim() === "") {
            console.error("Column title cannot be empty");
            throw new Error("Column title cannot be empty");
        }
        if (!(await columnExists(columnData.id))) {
            console.error(`Column with ID ${columnData.id} does not exist`);
            throw new Error("Column does not exist");
        }
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
