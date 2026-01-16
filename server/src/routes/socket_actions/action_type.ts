import { assigneeAssignAction } from "./assignee.assign";
import { assigneeListingAction } from "./assignee.list";
import { assigneeUnassignAction } from "./assignee.unassign";
import { cardCreationAction } from "./card.create";
import { cardDeletionAction } from "./card.delete";
import { cardListingAction } from "./card.list";
import { cardUpdateAction } from "./card.update";
import { columnCreationAction } from "./column.create";
import { columnDeletionAction } from "./column.delete";
import { columnListingAction } from "./column.list";
import { columnMoveAction } from "./column.move";
import { columnRenameAction } from "./column.rename";
import { messageAction } from "./chat.send";

export type SocketAction = {
    actionName: string;
    /*
     * The expected implementation of the execute function is to take a boardId
     * and a "data" object containing additional arguments required to execute
     * that action (i.e columnData for column.create), and return a Promise
     * that resolves to a created or modified resource.
     */
    execute(boardId: string, data: Object | null, userId: string): Promise<Object>;
};

export const actionIndex: SocketAction[] = [
    columnCreationAction,
    columnDeletionAction,
    columnRenameAction,
    columnListingAction,
    columnMoveAction,
    cardCreationAction,
    cardDeletionAction,
    cardUpdateAction,
    cardListingAction,
    assigneeAssignAction,
    assigneeUnassignAction,
    assigneeListingAction,
    messageAction
];
