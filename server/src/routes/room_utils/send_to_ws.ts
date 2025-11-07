import { ExtendedWebSocket } from "websocket-express";

export function sendToWs(ws: ExtendedWebSocket, payload: unknown): boolean {
    try {
        if (ws.readyState !== WebSocket.OPEN) return false;
        ws.send(JSON.stringify(payload));
        return true;
    } catch (err) {
        console.error(`Failed to send message to ws:`, err);
        return false;
    }
}
