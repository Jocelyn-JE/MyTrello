import { SocketAction } from "./action_type";
import { columnExists } from "../room_utils/get_column";
import { deleteColumn } from "../room_utils/delete_column";

type ColumnDeleteData = {
    id: string;
};

export const columnDeletionAction: SocketAction = {
    actionName: "column.delete",
    async execute(boardId: string, columnData: ColumnDeleteData, _userId: string) {
        console.info(
            `Deleting column with ID "${columnData.id}" from board ${boardId}`
        );
        if (!(await columnExists(columnData.id))) {
            console.error(`Column with ID ${columnData.id} does not exist`);
            throw new Error("Column does not exist");
        }
        const column = await deleteColumn(columnData.id);
        console.info(`Column deleted with ID: ${column.id}`);
        return column;
    }
};
