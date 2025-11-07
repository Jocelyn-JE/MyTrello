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
        const column = await prisma.column.create({
            data: {
                title: columnData.title,
                boardId,
                index: await prisma.column.count({
                    where: { boardId }
                })
            }
        });
        console.info(`Column created with ID: ${column.id}`);
        return column;
    }
};
