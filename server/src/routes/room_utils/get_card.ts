import { Card } from "@prisma/client";
import prisma from "../../utils/prisma.client";

export async function getCardInfo(cardId: string): Promise<Card | null> {
    try {
        const card = await prisma.card.findUnique({
            where: { id: cardId }
        });
        return card || null;
    } catch (error) {
        console.error(`Error fetching info for card ${cardId}:`, error);
        return null;
    }
}

export async function cardExists(cardId: string): Promise<boolean> {
    try {
        const exists = await prisma.card.findUnique({
            where: { id: cardId },
            select: { id: true }
        });
        return Boolean(exists);
    } catch (error) {
        console.error(`Error checking existence for card ${cardId}:`, error);
        return Promise.resolve(false);
    }
}
