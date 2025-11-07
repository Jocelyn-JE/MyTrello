import { Tag } from "@prisma/client";
import prisma from "../../utils/prisma.client";

export async function getTagInfo(tagId: string): Promise<Tag | null> {
    try {
        const tag = await prisma.tag.findUnique({
            where: { id: tagId }
        });
        return tag || null;
    } catch (error) {
        console.error(`Error fetching info for tag ${tagId}:`, error);
        return null;
    }
}

export async function tagExists(tagId: string): Promise<boolean> {
    try {
        const exists = await prisma.tag.findUnique({
            where: { id: tagId },
            select: { id: true }
        });
        return Boolean(exists);
    } catch (error) {
        console.error(`Error checking existence for tag ${tagId}:`, error);
        return Promise.resolve(false);
    }
}
