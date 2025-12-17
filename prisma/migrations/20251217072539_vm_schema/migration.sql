-- CreateTable
CREATE TABLE "VM" (
    "vmId" TEXT NOT NULL PRIMARY KEY,
    "ram_used_mb" INTEGER NOT NULL,
    "ram_total_mb" INTEGER NOT NULL,
    "cpu_used_pct" REAL NOT NULL,
    "disk_used_mb" INTEGER NOT NULL,
    "disk_total_mb" INTEGER NOT NULL,
    "timestamp" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- CreateIndex
CREATE UNIQUE INDEX "VM_vmId_key" ON "VM"("vmId");
