import { PrismaClient } from "@prisma/client"
import dotenv from "dotenv";
import { PrismaPg } from '@prisma/adapter-pg'
import path from "path";

dotenv.config({
    path: path.resolve(__dirname, "../../../.env"),
});

const DATABASE_URL = process.env.DATABASE_URL;
const connectionString = DATABASE_URL;

console.log("Connecting to database at:", connectionString);

if (!connectionString) {
    throw new Error("DATABASE_URL is not defined in environment variables");
}

const adapter = new PrismaPg({ connectionString })
const prisma = new PrismaClient({ adapter });

export const cleanupOldRecords = async () => {
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
        const unusedTokens = await prisma.token.deleteMany({
            where: {
                isUsed: false,
                expiresAt: {
                    lt: new Date()
                }
            }
        });
        console.log(`Deleted ${unusedTokens.count} unused expired tokens.`);
        const usedTokens = await prisma.token.deleteMany({
            where: {
                isUsed: true
            }
        });
        console.log(`Deleted ${usedTokens.count} used tokens.`);
    } catch (error) {
        console.error("Error during cleanup of old records:", error);
    } finally {
        await prisma.$disconnect();
    }
}