import { SocketAction } from "./action_type";
import prisma from "../../utils/prisma.client";
import { moveColumnAtIndex } from "../room_utils/move_column_at_index";

type ColumnMoveData = {
    id: string;
    newPos: string | null; // New position before which to move the column, if not provided, move to end
};

export const columnMoveAction: SocketAction = {
    actionName: "column.move",
    async execute(
        boardId: string,
        columnData: ColumnMoveData,
        _userId: string
    ) {
        console.info(
            `Moving column with ID "${columnData.id}" in board ${boardId}`
        );
        if (!columnData.id || columnData.id.trim() === "") {
            console.error("Column ID cannot be empty");
            throw new Error("Column ID cannot be empty");
        }
        await moveColumnAtIndex(columnData.newPos, columnData.id);
        const column = await prisma.column.findUnique({
            where: { id: columnData.id }
        });
        if (!column) {
            console.error(`Column with ID ${columnData.id} does not exist`);
            throw new Error("Column does not exist");
        }
        console.info(
            `Column moved with ID(${column.id}), new index: ${column.index}`
        );
        return column;
    }
};
