import prisma from "../../utils/prisma.client";
import {
    decrementCardIndicesAfter,
    incrementCardIndicesAfter
} from "./delete_card";
import { getCardInfo } from "./get_card";
import { getColumnInfo } from "./get_column";
import { getNextCardIndex } from "./get_next_card_index";

export async function moveCardAtIndex(
    targetColumnId: string | undefined = undefined,
    targetCardId: string | undefined = undefined,
    cardId: string
): Promise<void> {
    let cardToInsert = await getCardInfo(cardId);
    if (!cardToInsert) {
        console.error(`Card with ID ${cardId} does not exist`);
        throw new Error("Card does not exist");
    }
    // No move needed
    if (
        cardToInsert.columnId === targetColumnId &&
        cardToInsert.id === targetCardId
    ) {
        return;
    }
    if (targetColumnId === undefined) targetColumnId = cardToInsert.columnId;
    if (!(await getColumnInfo(targetColumnId))) {
        console.error(`Column with ID ${targetColumnId} does not exist`);
        throw new Error("Target column does not exist");
    }
    if (targetCardId !== undefined && !(await getCardInfo(targetCardId))) {
        console.error(`Card with ID ${targetCardId} does not exist`);
        throw new Error("Target card does not exist");
    }

    // Temporarily change the index of the card to be moved to avoid conflicts
    const minIndex = await prisma.card.aggregate({
        where: { columnId: cardToInsert.columnId },
        _min: { index: true }
    });
    const tempIndex = (minIndex._min.index ?? 0) - 1;

    await prisma.card.update({
        where: { id: cardId },
        data: {
            index: tempIndex
        }
    });
    await decrementCardIndicesAfter(cardToInsert.columnId, cardToInsert.index);

    // Determine the target index
    let targetIndex: number = 0;
    if (targetCardId === undefined) {
        // Insert at end
        targetIndex = await getNextCardIndex(targetColumnId);
    } else {
        let targetCard = await getCardInfo(targetCardId);
        if (!targetCard) {
            console.error(`Card with ID ${targetCardId} does not exist`);
            throw new Error("Target card does not exist");
        }
        targetIndex = targetCard.index;
        await incrementCardIndicesAfter(targetColumnId, targetIndex); // Make space for the moved card
    }
    await prisma.card.update({
        where: { id: cardId },
        data: {
            columnId: targetColumnId,
            index: targetIndex,
            updatedAt: new Date()
        }
    });
}
