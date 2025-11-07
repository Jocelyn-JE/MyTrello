import prisma from "../../utils/prisma.client";

export async function isUserViewer(
    userId: string,
    boardId: string
): Promise<boolean> {
    try {
        const exists = await prisma.board.findFirst({
            where: {
                id: boardId,
                viewers: { some: { id: userId } }
            },
            select: { id: true }
        });
        return Boolean(exists);
    } catch (error) {
        console.error(
            `Error checking viewer status for user ${userId} on board ${boardId}:`,
            error
        );
        return Promise.resolve(false);
    }
}
