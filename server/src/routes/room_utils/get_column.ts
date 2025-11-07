import { Column } from "@prisma/client";
import prisma from "../../utils/prisma.client";

export async function getColumnInfo(columnId: string): Promise<Column | null> {
    try {
        const column = await prisma.column.findUnique({
            where: { id: columnId }
        });
        return column || null;
    } catch (error) {
        console.error(`Error fetching info for column ${columnId}:`, error);
        return null;
    }
}

export async function columnExists(columnId: string): Promise<boolean> {
    try {
        const exists = await prisma.column.findUnique({
            where: { id: columnId },
            select: { id: true }
        });
        return Boolean(exists);
    } catch (error) {
        console.error(
            `Error checking existence for column ${columnId}:`,
            error
        );
        return Promise.resolve(false);
    }
}
