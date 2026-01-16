import { Board } from "@prisma/client";
import { BoardUser } from "./types";
import prisma from "../../utils/prisma.client";

export async function updateBoard(
    boardId: string,
    title: string,
    users: BoardUser[]
): Promise<Board> {
    const memberIds = users
        .filter((user) => user.role === "member")
        .map((user) => user.id);

    const viewerIds = users
        .filter((user) => user.role === "viewer")
        .map((user) => user.id);

    const members = await prisma.user.findMany({
        where: { id: { in: memberIds } }
    });

    const viewers = await prisma.user.findMany({
        where: { id: { in: viewerIds } }
    });

    return prisma.board.update({
        where: { id: boardId },
        data: {
            title,
            members: { set: members.map((user) => ({ id: user.id })) },
            viewers: { set: viewers.map((user) => ({ id: user.id })) }
        },
        include: {
            owner: { select: { id: true, username: true, email: true } },
            members: { select: { id: true, username: true, email: true } },
            viewers: { select: { id: true, username: true, email: true } }
        }
    });
}
