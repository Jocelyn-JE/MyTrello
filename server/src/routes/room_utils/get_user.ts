import prisma from "../../utils/prisma.client";

export type UserInfo = {
    username: string;
    email: string;
};

export async function getUserInfo(
    userId: string
): Promise<UserInfo | undefined> {
    try {
        const user = await prisma.user.findUnique({
            where: { id: userId },
            select: { username: true, email: true }
        });
        return user || undefined;
    } catch (error) {
        console.error(`Error fetching profile for user ${userId}:`, error);
        return undefined;
    }
}
