import { PrismaClient } from "@prisma/client";
import { PrismaPg } from '@prisma/adapter-pg'
import "dotenv/config";

const connectionString = process.env.DATABASE_URL;

console.log("Connecting to database at:", connectionString);

if (!connectionString) {
    throw new Error("DATABASE_URL is not defined in environment variables");
}

const adapter = new PrismaPg({ connectionString })
export const prisma = new PrismaClient({ adapter });