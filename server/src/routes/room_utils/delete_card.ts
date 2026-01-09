import prisma from "../../utils/prisma.client";

export async function deleteCard(cardId: string) {
    let card = await prisma.card.delete({
        where: {
            id: cardId
        }
    });
    decrementCardIndicesAfter(card.columnId, card.index);
    return card;
}

export async function decrementCardIndicesAfter(
    columnId: string,
    deletedIndex: number
): Promise<void> {
    const cardsToUpdate = await prisma.card.findMany({
        where: {
            columnId: columnId,
            index: {
                gt: deletedIndex
            }
        },
        orderBy: { index: "asc" }
    });

    for (const card of cardsToUpdate) {
        await prisma.card.update({
            where: { id: card.id },
            data: {
                index: card.index - 1
            }
        });
    }
}

export async function incrementCardIndicesAfter(
    columnId: string,
    startIndex: number
): Promise<void> {
    const cardsToUpdate = await prisma.card.findMany({
        where: {
            columnId: columnId,
            index: {
                gte: startIndex
            }
        },
        orderBy: { index: "desc" }
    });

    for (const card of cardsToUpdate) {
        await prisma.card.update({
            where: { id: card.id },
            data: {
                index: card.index + 1
            }
        });
    }
}
