import { ExtendedWebSocket } from "websocket-express";
import { sendToWs } from "./send_to_ws";

/*
 * Sends a payload to all WebSocket connections of a specific user.
 * Used when the calling user is not the recipient.
 * Returns true if at least one message was successfully sent.
 */
export function sendToUser(
    clients: Map<string, Set<ExtendedWebSocket>>,
    userId: string,
    payload: unknown
): boolean {
    const userWs = clients.get(userId);
    if (!userWs) return false;
    let result = false;
    for (const ws of Array.from(userWs)) {
        if (
            ws.readyState === WebSocket.CLOSED ||
            ws.readyState === WebSocket.CLOSING
        ) {
            userWs.delete(ws);
            continue;
        }
        result = sendToWs(ws, payload) || result;
    }
    if (userWs.size === 0) clients.delete(userId);
    if (!result)
        console.warn(
            `Failed to send message to user ${userId}: WebSocket not open`
        );
    return result;
}
