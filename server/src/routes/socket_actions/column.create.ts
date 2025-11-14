import { SocketAction } from "./action_type";
import prisma from "../../utils/prisma.client";

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
        
        // Find the maximum index and add 1, or use 0 if no columns exist
        const maxIndexColumn = await prisma.column.findFirst({
            where: { boardId },
            orderBy: { index: 'desc' },
            select: { index: true }
        });
        const nextIndex = maxIndexColumn ? maxIndexColumn.index + 1 : 0;
        
        const column = await prisma.column.create({
            data: {
                title: columnData.title,
                boardId,
                index: nextIndex,
                createdAt: new Date(),
                updatedAt: new Date()
            }
        });
        console.info(`Column created with ID: ${column.id}`);
        return column;
    }
};
