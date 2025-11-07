import { ExtendedWebSocket } from "websocket-express";
import { sendToWs } from "./send_to_ws";
import { actionIndex } from "../socket_actions/action_type";
import { getUserInfo, UserInfo } from "./get_user";

export type MessagePayload = {
    type: string;
    data: Object | null;
    sender?: UserInfo;
};

export class Room {
    private boardId: string;
    private users: ExtendedWebSocket[];

    constructor(boardId: string) {
        this.boardId = boardId;
        this.users = [];
    }

    public addUser(ws: ExtendedWebSocket) {
        if (!this.isUserInRoom(ws)) this.users.push(ws);
    }

    public isUserInRoom(ws: ExtendedWebSocket): boolean {
        return this.users.includes(ws);
    }

    public removeUser(ws: ExtendedWebSocket) {
        this.users = this.users.filter((userWs) => userWs !== ws);
    }

    public getUsers(): ExtendedWebSocket[] {
        return this.users;
    }

    public getBoardId(): string {
        return this.boardId;
    }

    public broadcast(sender: ExtendedWebSocket, data: MessagePayload) {
        for (const userWs of Array.from(this.users)) {
            if (userWs === sender) continue;
            if (
                userWs.readyState === WebSocket.CLOSED ||
                userWs.readyState === WebSocket.CLOSING
            ) {
                this.removeUser(userWs);
                continue;
            }
            if (userWs.readyState !== WebSocket.OPEN) continue;
            sendToWs(userWs, data);
        }
    }

    public async executeAction(
        client: ExtendedWebSocket,
        userId: string,
        { type: actionName, data }: MessagePayload
    ): Promise<void> {
        const action = actionIndex.find((act) => act.actionName === actionName);
        if (!action) {
            console.warn(`No action found for name: ${actionName}`);
            return;
        }
        let result = await action.execute(this.boardId, data);
        this.broadcast(client, {
            type: actionName,
            data: result,
            sender: await getUserInfo(userId)
        });
    }
}
