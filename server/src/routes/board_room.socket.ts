import { ExtendedWebSocket, Router } from "websocket-express";
import { WebSocket } from "ws";
import { getTokenPayload } from "../utils/jwt";
import prisma from "../utils/prisma.client";

type Room = {
    boardId: string;
    users: ExtendedWebSocket[];
};

const router = new Router();
const rooms: Map<string, Room> = new Map();
const clients: Map<string, Set<ExtendedWebSocket>> = new Map();

async function isUserMemberOfBoard(userId: string, boardId: string): Promise<boolean> {
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

//function sendToUser(userId: string, payload: unknown): boolean {
//    const userWs = clients.get(userId);
//    if (!userWs) return false;
//    let result = false;
//    for (const ws of Array.from(userWs)) {
//        if (ws.readyState === WebSocket.CLOSED || ws.readyState === WebSocket.CLOSING) {
//            userWs.delete(ws);
//            continue;
//        }
//        result = sendToWs(ws, payload) || result;
//    }
//    if (userWs.size === 0)
//        clients.delete(userId);
//    if (!result)
//        console.warn(`Failed to send message to user ${userId}: WebSocket not open`);
//    return result;
//}

function sendToWs(ws: ExtendedWebSocket, payload: unknown): boolean {
    try {
        if (ws.readyState !== WebSocket.OPEN) return false;
        ws.send(JSON.stringify(payload));
        return true;
    } catch (err) {
        console.error(`Failed to send message to ws:`, err);
        return false;
    }
}

function broadCastToRoom(
    sender: ExtendedWebSocket,
    users: ExtendedWebSocket[],
    data: unknown
) {
    for (const userWs of Array.from(users)) {
        if (userWs === sender) continue;
        if (
            userWs.readyState === WebSocket.CLOSED ||
            userWs.readyState === WebSocket.CLOSING
        ) {
            // remove stale socket from room list
            const idx = users.indexOf(userWs);
            if (idx !== -1) users.splice(idx, 1);
            continue;
        }
        if (userWs.readyState !== WebSocket.OPEN) continue;
        sendToWs(userWs, data);
    }
}

function handleConnect(userId: string, ws: ExtendedWebSocket, room: Room) {
    let userSockets = clients.get(userId);
    if (!userSockets) {
        userSockets = new Set();
        clients.set(userId, userSockets);
    }
    userSockets.add(ws);
    if (!room.users.includes(ws)) room.users.push(ws);
}

function handleDisconnect(userId: string, ws: ExtendedWebSocket, room: Room) {
    const userSockets = clients.get(userId);
    if (userSockets) {
        userSockets.delete(ws);
        if (userSockets.size === 0) clients.delete(userId);
    }
    room.users = room.users.filter((userWs) => userWs !== ws);
    if (room.users.length === 0) rooms.delete(room.boardId);
}

function createRoom(boardId: string): Room {
    const newRoom: Room = { boardId, users: [] };
    rooms.set(boardId, newRoom);
    return newRoom;
}

function onMessage(
    client: ExtendedWebSocket,
    message: unknown,
    room: Room,
    userId: string
) {
    try {
        const text =
            typeof message === "string" ? message : (message as any).toString();
        const payload = text ? JSON.parse(text) : null;
        console.debug(
            `Received message from user ${userId} in room ${room.boardId}:`,
            payload
        );
        broadCastToRoom(client, room.users, { userId, payload });
    } catch (err) {
        console.warn(`Invalid JSON from user ${userId}:`, err);
    }
}

router.ws("/connect/:boardId", async (req, res) => {
    console.debug(
        "/api/boards/connect/:boardId: Received board connection request"
    );
    const ws = await res.accept();
    const { boardId } = req.params;
    const message = await ws.nextMessage({ timeout: 1000 });
    const body =
        message && !message.isBinary && message.data && message.data.length > 0
            ? JSON.parse(message.data.toString())
            : null;
    const payload = body?.token
        ? await getTokenPayload(body.token)
        : null;
    const userId = payload?.userId;

    if (!userId) {
        console.error("No user ID found");
        return ws.close(1008, "Unauthorized: Invalid or missing token");
    }
    if (!boardId) {
        console.error("Board ID missing in request");
        return ws.close(1008, "Bad Request: Missing board ID");
    }
    const allowed = await isUserMemberOfBoard(userId, boardId);
    if (!allowed)
        return ws.close(1008, "Unauthorized: not a board member");
    try {
        let room = rooms.get(boardId);
        if (!room) room = createRoom(boardId);
        handleConnect(userId, ws, room);

        ws.on("message", async (message) => {
            onMessage(ws, message, room, userId);
        });
        ws.on("error", (err) => {
            console.warn(
                `WebSocket error for user ${userId} in room ${room.boardId}:`,
                err
            );
        });
        ws.on("close", () => {
            console.info(
                `User ${userId} disconnected from room ${room.boardId}`
            );
            handleDisconnect(userId, ws, room);
        });

        console.info(
            `User ${userId} connected to room ${room.boardId} successfully`
        );
        sendToWs(ws, {
            message: "Connected to board successfully",
            room: { boardId: room.boardId, userCount: room.users.length }
        });
    } catch (error: unknown) {
        const errorMessage =
            error instanceof Error ? error.message : "Unknown error occurred";
        console.error("Error during board room connection:", errorMessage);
        ws.close(1011, "Internal server error");
    }
});
