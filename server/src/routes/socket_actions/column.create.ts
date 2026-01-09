import { SocketAction } from "./action_type";
import prisma from "../../utils/prisma.client";
import { getNextColumnIndex } from "../room_utils/get_next_column_index";

type ColumnCreateData = {
    title: string;
};

export const columnCreationAction: SocketAction = {
    actionName: "column.create",
    async execute(boardId: string, columnData: ColumnCreateData) {
        console.info(
            `Creating column with title "${columnData.title}" in board ${boardId}`
        );
        if (!columnData.title || columnData.title.trim() === "") {
            console.error("Column title cannot be empty");
            throw new Error("Column title cannot be empty");
        }

        const column = await prisma.column.create({
            data: {
                title: columnData.title,
                boardId,
                index: await getNextColumnIndex(boardId),
                createdAt: new Date(),
                updatedAt: new Date()
            }
        });
        console.info(`Column created with ID: ${column.id}`);
        return column;
    }
};
