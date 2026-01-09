import prisma from "../../utils/prisma.client";

export async function deleteColumn(columnId: string) {
    let column = await prisma.column.delete({
        where: {
            id: columnId
        }
    });
    decrementColumnIndicesAfter(column.boardId, column.index);
    return column;
}

export async function decrementColumnIndicesAfter(
    boardId: string,
    deletedIndex: number
): Promise<void> {
    const columnsToUpdate = await prisma.column.findMany({
        where: {
            boardId: boardId,
            index: {
                gt: deletedIndex
            }
        },
        orderBy: { index: "asc" }
    });

    for (const column of columnsToUpdate) {
        await prisma.column.update({
            where: { id: column.id },
            data: {
                index: column.index - 1
            }
        });
    }
}

export async function incrementColumnIndicesAfter(
    boardId: string,
    startIndex: number
): Promise<void> {
    const columnsToUpdate = await prisma.column.findMany({
        where: {
            boardId: boardId,
            index: {
                gte: startIndex
            }
        },
        orderBy: { index: "desc" }
    });

    for (const column of columnsToUpdate) {
        await prisma.column.update({
            where: { id: column.id },
            data: {
                index: column.index + 1
            }
        });
    }
}
