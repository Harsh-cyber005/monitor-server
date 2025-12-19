/*
  Warnings:

  - Added the required column `status` to the `VM` table without a default value. This is not possible if the table is not empty.

*/
-- RedefineTables
PRAGMA defer_foreign_keys=ON;
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_VM" (
    "vmId" TEXT NOT NULL PRIMARY KEY,
    "ramUsedMB" INTEGER NOT NULL,
    "ramTotalMB" INTEGER NOT NULL,
    "cpuUsedPct" REAL NOT NULL,
    "diskUsedMB" INTEGER NOT NULL,
    "diskTotalMB" INTEGER NOT NULL,
    "timestamp" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "hostname" TEXT NOT NULL,
    "publicIp" TEXT NOT NULL,
    "status" TEXT NOT NULL
);
INSERT INTO "new_VM" ("cpuUsedPct", "diskTotalMB", "diskUsedMB", "hostname", "publicIp", "ramTotalMB", "ramUsedMB", "timestamp", "vmId") SELECT "cpuUsedPct", "diskTotalMB", "diskUsedMB", "hostname", "publicIp", "ramTotalMB", "ramUsedMB", "timestamp", "vmId" FROM "VM";
DROP TABLE "VM";
ALTER TABLE "new_VM" RENAME TO "VM";
CREATE INDEX "VM_vmId_timestamp_idx" ON "VM"("vmId", "timestamp");
CREATE UNIQUE INDEX "VM_vmId_timestamp_key" ON "VM"("vmId", "timestamp");
PRAGMA foreign_keys=ON;
PRAGMA defer_foreign_keys=OFF;
