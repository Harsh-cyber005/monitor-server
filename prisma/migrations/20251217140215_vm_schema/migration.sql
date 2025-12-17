/*
  Warnings:

  - The primary key for the `VM` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - You are about to drop the column `id` on the `VM` table. All the data in the column will be lost.
  - Added the required column `hostname` to the `VM` table without a default value. This is not possible if the table is not empty.
  - Added the required column `publicIp` to the `VM` table without a default value. This is not possible if the table is not empty.

*/
-- RedefineTables
PRAGMA defer_foreign_keys=ON;
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_VM" (
    "vmId" TEXT NOT NULL PRIMARY KEY,
    "status" TEXT NOT NULL,
    "ramUsedMB" INTEGER NOT NULL,
    "ramTotalMB" INTEGER NOT NULL,
    "cpuUsedPct" REAL NOT NULL,
    "diskUsedMB" INTEGER NOT NULL,
    "diskTotalMB" INTEGER NOT NULL,
    "timestamp" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "hostname" TEXT NOT NULL,
    "publicIp" TEXT NOT NULL
);
INSERT INTO "new_VM" ("cpuUsedPct", "diskTotalMB", "diskUsedMB", "ramTotalMB", "ramUsedMB", "status", "timestamp", "vmId") SELECT "cpuUsedPct", "diskTotalMB", "diskUsedMB", "ramTotalMB", "ramUsedMB", "status", "timestamp", "vmId" FROM "VM";
DROP TABLE "VM";
ALTER TABLE "new_VM" RENAME TO "VM";
CREATE INDEX "VM_vmId_timestamp_idx" ON "VM"("vmId", "timestamp");
CREATE UNIQUE INDEX "VM_vmId_timestamp_key" ON "VM"("vmId", "timestamp");
PRAGMA foreign_keys=ON;
PRAGMA defer_foreign_keys=OFF;
