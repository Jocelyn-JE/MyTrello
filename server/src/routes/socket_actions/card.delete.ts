import { SocketAction } from "./action_type";
import { cardExists } from "../room_utils/get_card";
import { deleteCard } from "../room_utils/delete_card";

type CardDeleteData = {
    id: string;
};

export const cardDeletionAction: SocketAction = {
    actionName: "card.delete",
    async execute(boardId: string, cardData: CardDeleteData) {
        console.info(
            `Deleting card with ID "${cardData.id}" from board ${boardId}`
        );
        if (!(await cardExists(cardData.id))) {
            console.error(`Card with ID ${cardData.id} does not exist`);
            throw new Error("Card does not exist");
        }
        const card = await deleteCard(cardData.id);
        console.info(`Card deleted with ID: ${card.id}`);
        return card;
    }
};
