import { Board } from "@prisma/client";
import prisma from "../../utils/prisma.client";

export async function getBoardInfo(boardId: string): Promise<Board | null> {
    try {
        const board = await prisma.board.findUnique({
            where: { id: boardId }
        });
        return board || null;
    } catch (error) {
        console.error(`Error fetching info for board ${boardId}:`, error);
        return null;
    }
}

export async function boardExists(boardId: string): Promise<boolean> {
    try {
        const exists = await prisma.board.findUnique({
            where: { id: boardId },
            select: { id: true }
        });
        return Boolean(exists);
    } catch (error) {
        console.error(`Error checking existence for board ${boardId}:`, error);
        return Promise.resolve(false);
    }
}
