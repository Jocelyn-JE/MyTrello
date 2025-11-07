import { SocketAction } from "./action_type";

export const messageAction: SocketAction = {
    actionName: "message",
    async execute(boardId: string, data: string) {
        console.info(`Message "${data}" sent in board ${boardId}`);
        return data;
    }
};
