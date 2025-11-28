import { BoardUser } from "./types";

export function isBoardUser(user: unknown): user is BoardUser {
    return (
        typeof user === "object" &&
        user !== null &&
        "id" in user &&
        "role" in user &&
        typeof (user as any).id === "string" &&
        ((user as any).role === "member" || (user as any).role === "viewer")
    );
}
