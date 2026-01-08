import prisma from "../../utils/prisma.client";
import { getCardInfo } from "./get_card";
import { getLastColumnIndex } from "./get_last_column_index";

export async function moveCardAtIndex(
    targetColumnId: string | undefined = undefined,
    targetIndex: number | undefined = undefined,
    cardId: string
): Promise<void> {
    let cardToInsert = await getCardInfo(cardId);
    if (!cardToInsert) {
        console.error(`Card with ID ${cardId} does not exist`);
        throw new Error("Card does not exist");
    }
    if (targetColumnId === undefined) targetColumnId = cardToInsert.columnId;
    if (targetIndex === undefined)
        targetIndex = (await getLastColumnIndex(targetColumnId)) + 1;
    await decrementIndicesAfterMove(cardToInsert.columnId, cardToInsert.index);
    // Adjust target index if moving within the same column downwards (to account for the removed card)
    if (
        cardToInsert.index > targetIndex &&
        cardToInsert.columnId === targetColumnId
    )
        targetIndex -= 1;
    await incrementIndicesAfterMove(targetColumnId, targetIndex);
    // Update the card to be inserted with the new index and columnId
    await prisma.card.update({
        where: { id: cardId },
        data: {
            index: targetIndex,
            columnId: targetColumnId
        }
    });
}

// Helper function to decrement indices of cards after a card is moved out
async function decrementIndicesAfterMove(
    columnId: string,
    startIndex: number
): Promise<void> {
    await prisma.card.updateMany({
        where: {
            columnId: columnId,
            index: {
                gt: startIndex
            }
        },
        data: {
            index: {
                decrement: 1
            }
        }
    });
}

// Helper function to increment indices of cards after a card is moved in
async function incrementIndicesAfterMove(
    columnId: string,
    startIndex: number
): Promise<void> {
    await prisma.card.updateMany({
        where: {
            columnId: columnId,
            index: {
                gte: startIndex
            }
        },
        data: {
            index: {
                increment: 1
            }
        }
    });
}
