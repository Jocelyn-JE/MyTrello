import prisma from "./prisma.client";

/**
 * Checks if a user has access to a board (as owner, member, or viewer)
 * @param userId - The ID of the user to check
 * @param boardId - The ID of the board to check access for
 * @returns Promise<boolean> - True if user has access, false otherwise
 */
export async function isUserPartOfBoard(
    userId: string,
    boardId: string
): Promise<boolean> {
    try {
        const board = await prisma.board.findFirst({
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
        return board !== null;
    } catch (error) {
        console.error("Error checking board access:", error);
        return false;
    }
}
