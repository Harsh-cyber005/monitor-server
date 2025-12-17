import "dotenv/config";
import { prisma } from "../db/prisma";

const cleanupOldRecords = async () => {
    const ttlInDays = 7;
    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() - ttlInDays);
    try {
        const deletedRecords = await prisma.vM.deleteMany({
            where: {
                timestamp: {
                    lt: cutoffDate
                }
            }
        });
        await prisma.$executeRawUnsafe("VACUUM");
        await prisma.$disconnect();
        console.log(`Deleted ${deletedRecords.count} old records.`);
    } catch (error) {
        console.error("Error during cleanup of old records:", error);
    }
}

cleanupOldRecords();