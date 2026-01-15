import prisma from "../../utils/prisma.client";
import {
    decrementColumnIndicesAfter,
    incrementColumnIndicesAfter
} from "./delete_column";
import { getColumnInfo } from "./get_column";
import { getNextColumnIndex } from "./get_next_column_index";

export async function moveColumnAtIndex(
    targetColumnId: string | undefined = undefined,
    columnId: string
): Promise<void> {
    let columnToInsert = await getColumnInfo(columnId);
    if (!columnToInsert) {
        console.error(`Column with ID ${columnId} does not exist`);
        throw new Error("Column does not exist");
    }
    // No move needed
    if (columnToInsert.id === targetColumnId) {
        return;
    }
    if (
        targetColumnId !== undefined &&
        !(await getColumnInfo(targetColumnId))
    ) {
        console.error(`Column with ID ${targetColumnId} does not exist`);
        throw new Error("Target column does not exist");
    }

    // Temporarily change the index of the column to be moved to avoid conflicts
    const minIndex = await prisma.column.aggregate({
        where: { boardId: columnToInsert.boardId },
        _min: { index: true }
    });
    const tempIndex = (minIndex._min.index ?? 0) - 1;

    await prisma.column.update({
        where: { id: columnId },
        data: {
            index: tempIndex
        }
    });
    await decrementColumnIndicesAfter(
        columnToInsert.boardId,
        columnToInsert.index
    );

    // Determine the target index
    let targetIndex: number = 0;
    if (targetColumnId === undefined) {
        // Insert at end
        targetIndex = await getNextColumnIndex(columnToInsert.boardId);
    } else {
        let targetColumn = await getColumnInfo(targetColumnId);
        if (!targetColumn) {
            console.error(`Column with ID ${targetColumnId} does not exist`);
            throw new Error("Target column does not exist");
        }
        targetIndex = targetColumn.index;
        await incrementColumnIndicesAfter(columnToInsert.boardId, targetIndex); // Make space for the moved column
    }
    await prisma.column.update({
        where: { id: columnId },
        data: {
            boardId: columnToInsert.boardId,
            index: targetIndex,
            updatedAt: new Date()
        }
    });
}
