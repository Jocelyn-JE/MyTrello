import { ExtendedWebSocket } from "websocket-express";
import { AckPayload, ErrorPayload, MessagePayload } from "./room";

export function sendToWs(
    ws: ExtendedWebSocket,
    payload: MessagePayload | AckPayload | ErrorPayload
): boolean {
    try {
        if (ws.readyState !== WebSocket.OPEN) return false;
        ws.send(JSON.stringify(payload));
        return true;
    } catch (err) {
        console.error(`Failed to send message to ws:`, err);
        return false;
    }
}
