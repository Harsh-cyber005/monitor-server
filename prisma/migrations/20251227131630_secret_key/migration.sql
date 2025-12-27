/*
  Warnings:

  - Added the required column `vmName` to the `VM` table without a default value. This is not possible if the table is not empty.

*/
-- CreateTable
CREATE TABLE "VMAuth" (
    "vmId" TEXT NOT NULL PRIMARY KEY,
    "vmName" TEXT NOT NULL,
    "vmSecretKey" TEXT NOT NULL,
    "establishedAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "isEstablished" BOOLEAN NOT NULL DEFAULT false
);

-- RedefineTables
PRAGMA defer_foreign_keys=ON;
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_Metric" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "vmId" TEXT NOT NULL,
    "status" TEXT NOT NULL,
    "ramUsedMB" INTEGER NOT NULL,
    "ramTotalMB" INTEGER NOT NULL,
    "cpuUsedPct" REAL NOT NULL,
    "diskUsedMB" INTEGER NOT NULL,
    "diskTotalMB" INTEGER NOT NULL,
    "timestamp" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "hostname" TEXT NOT NULL,
    "publicIp" TEXT NOT NULL,
    CONSTRAINT "Metric_vmId_fkey" FOREIGN KEY ("vmId") REFERENCES "VM" ("vmId") ON DELETE CASCADE ON UPDATE CASCADE
);
INSERT INTO "new_Metric" ("cpuUsedPct", "diskTotalMB", "diskUsedMB", "hostname", "id", "publicIp", "ramTotalMB", "ramUsedMB", "status", "timestamp", "vmId") SELECT "cpuUsedPct", "diskTotalMB", "diskUsedMB", "hostname", "id", "publicIp", "ramTotalMB", "ramUsedMB", "status", "timestamp", "vmId" FROM "Metric";
DROP TABLE "Metric";
ALTER TABLE "new_Metric" RENAME TO "Metric";
CREATE INDEX "Metric_vmId_timestamp_idx" ON "Metric"("vmId", "timestamp");
CREATE TABLE "new_VM" (
    "vmId" TEXT NOT NULL PRIMARY KEY,
    "vmName" TEXT NOT NULL,
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
INSERT INTO "new_VM" ("cpuUsedPct", "diskTotalMB", "diskUsedMB", "hostname", "publicIp", "ramTotalMB", "ramUsedMB", "status", "timestamp", "vmId") SELECT "cpuUsedPct", "diskTotalMB", "diskUsedMB", "hostname", "publicIp", "ramTotalMB", "ramUsedMB", "status", "timestamp", "vmId" FROM "VM";
DROP TABLE "VM";
ALTER TABLE "new_VM" RENAME TO "VM";
CREATE INDEX "VM_vmId_timestamp_idx" ON "VM"("vmId", "timestamp");
CREATE UNIQUE INDEX "VM_vmId_timestamp_key" ON "VM"("vmId", "timestamp");
PRAGMA foreign_keys=ON;
PRAGMA defer_foreign_keys=OFF;
