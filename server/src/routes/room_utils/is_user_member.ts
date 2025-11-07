import prisma from "../../utils/prisma.client";

export async function isUserMemberOfBoard(
    userId: string,
    boardId: string
): Promise<boolean> {
    try {
        const exists = await prisma.board.findFirst({
            where: {
                id: boardId,
                OR: [
                    { ownerId: userId },
                    { members: { some: { id: userId } } },
                    { viewers: { some: { id: userId } } }
                ]
            },
            select: { id: true }
        });
        return Boolean(exists);
    } catch (error) {
        console.error(
            `Error checking membership for user ${userId} on board ${boardId}:`,
            error
        );
        return Promise.resolve(false);
    }
}
