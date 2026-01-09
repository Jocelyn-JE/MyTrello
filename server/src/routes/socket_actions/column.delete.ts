import { SocketAction } from "./action_type";
import prisma from "../../utils/prisma.client";
import { columnExists } from "../room_utils/get_column";

type ColumnDeleteData = {
    id: string;
};

export const columnDeletionAction: SocketAction = {
    actionName: "column.delete",
    async execute(boardId: string, columnData: ColumnDeleteData) {
        console.info(
            `Deleting column with ID "${columnData.id}" from board ${boardId}`
        );
        if (!(await columnExists(columnData.id))) {
            console.error(`Column with ID ${columnData.id} does not exist`);
            throw new Error("Column does not exist");
        }
        const column = await prisma.column.delete({
            where: {
                id: columnData.id
            }
        });
        await updateColumnIndicesAfterDeletion(boardId, column.index);
        console.info(`Column deleted with ID: ${column.id}`);
        return column;
    }
};

async function updateColumnIndicesAfterDeletion(
    boardId: string,
    deletedIndex: number
): Promise<void> {
    await prisma.column.updateMany({
        where: {
            boardId: boardId,
            index: {
                gt: deletedIndex
            }
        },
        data: {
            index: {
                decrement: 1
            }
        }
    });
}
