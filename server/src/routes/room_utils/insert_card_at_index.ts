import prisma from "../../utils/prisma.client";
import { getCardInfo } from "./get_card";
import { getLastColumnIndex } from "./get_last_column_index";

export async function insertCardAtIndex(
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
    // Increment indices of cards at or beyond the target index
    await prisma.card.updateMany({
        where: {
            columnId: targetColumnId,
            index: {
                gte: targetIndex
            }
        },
        data: {
            index: {
                increment: 1
            }
        }
    });
    // Update the card to be inserted with the new index and columnId
    await prisma.card.update({
        where: { id: cardId },
        data: {
            index: targetIndex,
            columnId: targetColumnId
        }
    });
}
