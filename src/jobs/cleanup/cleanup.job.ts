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
    const establishmentCutoffDate = new Date();
    establishmentCutoffDate.setDate(establishmentCutoffDate.getDate() - 1);
    try {
        console.log("Starting cleanup of old records on:", new Date().toISOString());
        const deletedRecords = await prisma.metric.deleteMany({
            where: {
                timestamp: {
                    lt: cutoffDate
                }
            }
        });
        console.log(`Deleted ${deletedRecords.count} old records.`);
        const deletedAuths = await prisma.vM.deleteMany({
            where: {
                auth: {
                    isEstablished: false,
                    createdAt: {
                        lt: establishmentCutoffDate
                    }
                }
            }
        });
        console.log(`Deleted ${deletedAuths.count} stale VM auth records.`);
        await prisma.$executeRawUnsafe("VACUUM");
    } catch (error) {
        console.error("Error during cleanup of old records:", error);
    } finally {
        await prisma.$disconnect();
    }
}

cleanupOldRecords();