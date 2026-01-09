import prisma from "../../utils/prisma.client";

export async function getNextColumnIndex(boardId: string): Promise<number> {
    const count = await prisma.column.count({
        where: { boardId: boardId }
    });
    return count; // Next index is equal to the current count of columns
}
