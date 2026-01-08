import prisma from "../../utils/prisma.client";

export async function getLastColumnIndex(columnId: string): Promise<number> {
    const maxIndexCard = await prisma.card.findFirst({
        where: { columnId: columnId },
        orderBy: { index: "desc" },
        select: { index: true }
    });
    return maxIndexCard ? maxIndexCard.index : -1; // Return -1 if no cards exist in the column
}
