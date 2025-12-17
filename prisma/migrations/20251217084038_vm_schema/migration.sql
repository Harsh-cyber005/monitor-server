/*
  Warnings:

  - The primary key for the `VM` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - Added the required column `id` to the `VM` table without a default value. This is not possible if the table is not empty.

*/
-- RedefineTables
PRAGMA defer_foreign_keys=ON;
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_VM" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "vmId" TEXT NOT NULL,
    "status" TEXT NOT NULL,
    "ramUsedMB" INTEGER NOT NULL,
    "ramTotalMB" INTEGER NOT NULL,
    "cpuUsedPct" REAL NOT NULL,
    "diskUsedMB" INTEGER NOT NULL,
    "diskTotalMB" INTEGER NOT NULL,
    "timestamp" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO "new_VM" ("cpuUsedPct", "diskTotalMB", "diskUsedMB", "ramTotalMB", "ramUsedMB", "status", "timestamp", "vmId") SELECT "cpuUsedPct", "diskTotalMB", "diskUsedMB", "ramTotalMB", "ramUsedMB", "status", "timestamp", "vmId" FROM "VM";
DROP TABLE "VM";
ALTER TABLE "new_VM" RENAME TO "VM";
CREATE INDEX "VM_vmId_timestamp_idx" ON "VM"("vmId", "timestamp");
PRAGMA foreign_keys=ON;
PRAGMA defer_foreign_keys=OFF;
