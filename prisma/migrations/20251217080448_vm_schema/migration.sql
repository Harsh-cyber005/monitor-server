/*
  Warnings:

  - You are about to drop the column `cpu_used_pct` on the `VM` table. All the data in the column will be lost.
  - You are about to drop the column `disk_total_mb` on the `VM` table. All the data in the column will be lost.
  - You are about to drop the column `disk_used_mb` on the `VM` table. All the data in the column will be lost.
  - You are about to drop the column `ram_total_mb` on the `VM` table. All the data in the column will be lost.
  - You are about to drop the column `ram_used_mb` on the `VM` table. All the data in the column will be lost.
  - Added the required column `cpuUsed` to the `VM` table without a default value. This is not possible if the table is not empty.
  - Added the required column `diskTotalMB` to the `VM` table without a default value. This is not possible if the table is not empty.
  - Added the required column `diskUsedMB` to the `VM` table without a default value. This is not possible if the table is not empty.
  - Added the required column `ramTotalMB` to the `VM` table without a default value. This is not possible if the table is not empty.
  - Added the required column `ramUsedMB` to the `VM` table without a default value. This is not possible if the table is not empty.

*/
-- RedefineTables
PRAGMA defer_foreign_keys=ON;
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_VM" (
    "vmId" TEXT NOT NULL PRIMARY KEY,
    "status" TEXT NOT NULL,
    "ramUsedMB" INTEGER NOT NULL,
    "ramTotalMB" INTEGER NOT NULL,
    "cpuUsed" REAL NOT NULL,
    "diskUsedMB" INTEGER NOT NULL,
    "diskTotalMB" INTEGER NOT NULL,
    "timestamp" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO "new_VM" ("status", "timestamp", "vmId") SELECT "status", "timestamp", "vmId" FROM "VM";
DROP TABLE "VM";
ALTER TABLE "new_VM" RENAME TO "VM";
CREATE UNIQUE INDEX "VM_vmId_key" ON "VM"("vmId");
PRAGMA foreign_keys=ON;
PRAGMA defer_foreign_keys=OFF;
