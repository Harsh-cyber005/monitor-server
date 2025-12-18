/*
  Warnings:

  - You are about to drop the column `status` on the `VM` table. All the data in the column will be lost.

*/
-- CreateTable
CREATE TABLE "Metric" (
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

-- RedefineTables
PRAGMA defer_foreign_keys=ON;
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_VM" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "vmId" TEXT NOT NULL,
    "ramUsedMB" INTEGER NOT NULL,
    "ramTotalMB" INTEGER NOT NULL,
    "cpuUsedPct" REAL NOT NULL,
    "diskUsedMB" INTEGER NOT NULL,
    "diskTotalMB" INTEGER NOT NULL,
    "timestamp" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "hostname" TEXT NOT NULL,
    "publicIp" TEXT NOT NULL
);
INSERT INTO "new_VM" ("cpuUsedPct", "diskTotalMB", "diskUsedMB", "hostname", "id", "publicIp", "ramTotalMB", "ramUsedMB", "timestamp", "vmId") SELECT "cpuUsedPct", "diskTotalMB", "diskUsedMB", "hostname", "id", "publicIp", "ramTotalMB", "ramUsedMB", "timestamp", "vmId" FROM "VM";
DROP TABLE "VM";
ALTER TABLE "new_VM" RENAME TO "VM";
CREATE INDEX "VM_vmId_timestamp_idx" ON "VM"("vmId", "timestamp");
CREATE UNIQUE INDEX "VM_vmId_timestamp_key" ON "VM"("vmId", "timestamp");
PRAGMA foreign_keys=ON;
PRAGMA defer_foreign_keys=OFF;

-- CreateIndex
CREATE INDEX "Metric_vmId_timestamp_idx" ON "Metric"("vmId", "timestamp");
