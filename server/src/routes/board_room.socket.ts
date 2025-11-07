import { ExtendedWebSocket, Router } from "websocket-express";
import { getTokenPayload } from "../utils/jwt";
import prisma from "../utils/prisma.client";
import { sendToWs } from "./room_utils/send_to_ws";
import { MessagePayload, Room } from "./room_utils/room";
import { getBoardInfo } from "./room_utils/get_board";

const router = new Router();
const rooms: Map<string, Room> = new Map();
const clients: Map<string, Set<ExtendedWebSocket>> = new Map();

async function isUserMemberOfBoard(
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

async function isUserViewer(userId: string, boardId: string): Promise<boolean> {
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

function handleConnect(userId: string, ws: ExtendedWebSocket, room: Room) {
    let userSockets = clients.get(userId);
    if (!userSockets) {
        userSockets = new Set();
        clients.set(userId, userSockets);
    }
    userSockets.add(ws);
    room.addUser(ws);
}

function handleDisconnect(userId: string, ws: ExtendedWebSocket, room: Room) {
    const userSockets = clients.get(userId);
    if (userSockets) {
        userSockets.delete(ws);
        if (userSockets.size === 0) clients.delete(userId);
    }
    room.removeUser(ws);
    if (room.getUsers().length === 0) rooms.delete(room.getBoardId());
}

function createRoom(boardId: string): Room {
    const newRoom: Room = new Room(boardId);
    rooms.set(boardId, newRoom);
    return newRoom;
}

async function onMessage(
    client: ExtendedWebSocket,
    message: unknown,
    room: Room,
    userId: string
) {
    try {
        const text: string =
            typeof message === "string" ? message : (message as any).toString();
        const payload: MessagePayload | null = text ? JSON.parse(text) : null;
        console.debug(
            `Received message from user ${userId} in room ${room.getBoardId()}:`,
            payload
        );
        if (!payload || !payload.type) {
            console.warn(`Invalid message payload from user ${userId}:`, text);
            return;
        }
        await room.executeAction(client, userId, payload);
    } catch (err) {
        console.warn(`Invalid request from user ${userId}:`, err);
    }
}

async function getConnectionAcknowledgement(boardId: string): Promise<unknown> {
    const board = await getBoardInfo(boardId);
    if (!board) return { type: "error", message: "Board not found" };
    return { type: "connection_ack", board };
}

function closeError(message: string): string {
    return JSON.stringify({ type: "error", message });
}

router.ws("/:boardId", async (req, res) => {
    console.debug("/ws/boards/:boardId: Received board connection request");
    const ws = await res.accept();
    const { boardId } = req.params;
    const message = await ws.nextMessage({ timeout: 1000 });
    const body =
        message && !message.isBinary && message.data && message.data.length > 0
            ? JSON.parse(message.data.toString())
            : null;
    const payload = body?.token ? await getTokenPayload(body.token) : null;
    const userId = payload?.userId;

    if (!userId) {
        return ws.close(
            1008,
            closeError("Unauthorized: Invalid or missing token")
        );
    }
    if (!boardId) {
        console.error("Board ID missing in request");
        return ws.close(1008, closeError("Bad Request: Missing board ID"));
    }
    const allowed = await isUserMemberOfBoard(userId, boardId);
    if (!allowed)
        return ws.close(1008, closeError("Unauthorized: not a board member"));
    try {
        let room = rooms.get(boardId);
        if (!room) room = createRoom(boardId);
        handleConnect(userId, ws, room);

        if (!(await isUserViewer(userId, boardId))) {
            // only non-viewers can send messages
            ws.on("message", async (message) => {
                onMessage(ws, message, room, userId);
            });
        }
        ws.on("error", (err) => {
            console.warn(
                `WebSocket error for user ${userId} in room ${boardId}:`,
                err
            );
        });
        ws.on("close", () => {
            console.info(`User ${userId} disconnected from room ${boardId}`);
            handleDisconnect(userId, ws, room);
        });

        console.info(
            `User ${userId} connected to room ${boardId} successfully`
        );
        sendToWs(ws, await getConnectionAcknowledgement(boardId));
    } catch (error: unknown) {
        const errorMessage =
            error instanceof Error ? error.message : "Unknown error occurred";
        console.error("Error during board room connection:", errorMessage);
        ws.close(1011, closeError("Internal server error"));
    }
});

export default router;
