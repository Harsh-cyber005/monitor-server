import { PrismaBetterSqlite3 } from "@prisma/adapter-better-sqlite3";
import { PrismaClient } from "@prisma/client"

const DATABASE_URL = "file:./dev.db";
const connectionString = DATABASE_URL;

console.log("Connecting to database at:", connectionString);

if (!connectionString) {
    throw new Error("DATABASE_URL is not defined in environment variables");
}

const adapter = new PrismaBetterSqlite3({ url: connectionString });
const prisma = new PrismaClient({
    adapter
});

const cleanupOldRecords = async () => {
    const ttlInDays = 7;
    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() - ttlInDays);
    try {
        const deletedRecords = await prisma.metric.deleteMany({
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