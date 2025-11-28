import { Board, User } from "@prisma/client";
import { BoardUser } from "./types";
import prisma from "../../utils/prisma.client";

export async function createBoard(
    ownerId: string,
    title: string,
    users: BoardUser[]
): Promise<Board> {
    const memberIds = users
        .filter((user) => user.role === "member")
        .map((user) => user.id);

    const viewerIds = users
        .filter((user) => user.role === "viewer")
        .map((user) => user.id);

    // Only query if there are IDs to find
    const members: User[] =
        memberIds.length > 0
            ? await prisma.user.findMany({
                  where: { id: { in: memberIds } }
              })
            : [];

    const viewers: User[] =
        viewerIds.length > 0
            ? await prisma.user.findMany({
                  where: { id: { in: viewerIds } }
              })
            : [];

    return prisma.board.create({
        data: {
            title,
            owner: { connect: { id: ownerId } },
            members: { connect: members.map((user) => ({ id: user.id })) },
            viewers: { connect: viewers.map((user) => ({ id: user.id })) }
        },
        include: {
            owner: { select: { id: true, username: true } },
            members: { select: { id: true, username: true } },
            viewers: { select: { id: true, username: true } }
        }
    });
}
