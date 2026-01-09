import prisma from "../../utils/prisma.client";

export async function getNextCardIndex(columnId: string): Promise<number> {
    const count = await prisma.card.count({
        where: {
            columnId: columnId,
            index: {
                gte: 0
            }
        }
    });
    return count;
}
