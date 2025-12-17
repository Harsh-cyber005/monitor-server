/*
  Warnings:

  - Added the required column `status` to the `VM` table without a default value. This is not possible if the table is not empty.

*/
-- RedefineTables
PRAGMA defer_foreign_keys=ON;
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_VM" (
    "vmId" TEXT NOT NULL PRIMARY KEY,
    "status" TEXT NOT NULL,
    "ram_used_mb" INTEGER NOT NULL,
    "ram_total_mb" INTEGER NOT NULL,
    "cpu_used_pct" REAL NOT NULL,
    "disk_used_mb" INTEGER NOT NULL,
    "disk_total_mb" INTEGER NOT NULL,
    "timestamp" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO "new_VM" ("cpu_used_pct", "disk_total_mb", "disk_used_mb", "ram_total_mb", "ram_used_mb", "timestamp", "vmId") SELECT "cpu_used_pct", "disk_total_mb", "disk_used_mb", "ram_total_mb", "ram_used_mb", "timestamp", "vmId" FROM "VM";
DROP TABLE "VM";
ALTER TABLE "new_VM" RENAME TO "VM";
CREATE UNIQUE INDEX "VM_vmId_key" ON "VM"("vmId");
PRAGMA foreign_keys=ON;
PRAGMA defer_foreign_keys=OFF;
