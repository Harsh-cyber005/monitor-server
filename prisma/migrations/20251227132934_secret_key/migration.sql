/*
  Warnings:

  - You are about to drop the column `vmSecretKey` on the `VMAuth` table. All the data in the column will be lost.
  - Added the required column `secretHash` to the `VMAuth` table without a default value. This is not possible if the table is not empty.

*/
-- DropIndex
DROP INDEX "VM_vmId_timestamp_key";

-- RedefineTables
PRAGMA defer_foreign_keys=ON;
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_VMAuth" (
    "vmId" TEXT NOT NULL PRIMARY KEY,
    "vmName" TEXT NOT NULL,
    "secretHash" TEXT NOT NULL,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "establishedAt" DATETIME,
    "isEstablished" BOOLEAN NOT NULL DEFAULT false,
    CONSTRAINT "VMAuth_vmId_fkey" FOREIGN KEY ("vmId") REFERENCES "VM" ("vmId") ON DELETE CASCADE ON UPDATE CASCADE
);
INSERT INTO "new_VMAuth" ("establishedAt", "isEstablished", "vmId", "vmName") SELECT "establishedAt", "isEstablished", "vmId", "vmName" FROM "VMAuth";
DROP TABLE "VMAuth";
ALTER TABLE "new_VMAuth" RENAME TO "VMAuth";
PRAGMA foreign_keys=ON;
PRAGMA defer_foreign_keys=OFF;
