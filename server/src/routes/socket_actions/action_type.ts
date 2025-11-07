import { cardCreationAction } from "./card.create";
import { columnCreationAction } from "./column.create";
import { columnDeletionAction } from "./column.delete";
import { columnListingAction } from "./column.list";
import { columnRenameAction } from "./column.rename";
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
    columnDeletionAction,
    columnRenameAction,
    columnListingAction,
    cardCreationAction,
    messageAction
];
