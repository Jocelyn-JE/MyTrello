import { columnCreationAction } from "./column.create";
import { columnListingAction } from "./column.list";
import { messageAction } from "./message";

export type SocketAction = {
    actionName: string;
    /*
     * The expected implementation of the execute function is to take a boardId
     * and a "data" object containing additional arguments required to execute
     * that action (i.e columnData for column.create), and return a Promise
     * that resolves to a created or modified resource.
     */
    execute(boardId: string, data: Object | null): Promise<Object>;
};

export const actionIndex: SocketAction[] = [
    columnCreationAction,
    columnListingAction,
    messageAction
];

export function executeAction(
    actionName: string,
    boardId: string,
    data: Object
): Promise<Object> | undefined {
    const action = actionIndex.find((act) => act.actionName === actionName);
    if (action) return action.execute(boardId, data);
    console.warn(`No action found for name: ${actionName}`);
    return undefined;
}
