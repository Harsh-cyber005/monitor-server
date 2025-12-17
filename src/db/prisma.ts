import { PrismaBetterSqlite3 } from "@prisma/adapter-better-sqlite3";
import { PrismaClient } from "@prisma/client"

const connectionString = process.env.DATABASE_URL;

console.log("Connecting to database at:", connectionString);

if (!connectionString) {
    throw new Error("DATABASE_URL is not defined in environment variables");
}

const adapter = new PrismaBetterSqlite3({ url: connectionString });
export const prisma = new PrismaClient({
    adapter
});

//for sqlite we need adapters
// https://www.prisma.io/docs/getting-started/prisma-orm/add-to-existing-project/sqlite