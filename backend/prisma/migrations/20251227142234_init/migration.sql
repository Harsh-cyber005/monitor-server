-- CreateTable
CREATE TABLE "VM" (
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

-- CreateTable
CREATE TABLE "Metric" (
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

-- CreateTable
CREATE TABLE "VMAuth" (
    "vmId" TEXT NOT NULL PRIMARY KEY,
    "vmName" TEXT NOT NULL,
    "secretHash" TEXT NOT NULL,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "establishedAt" DATETIME,
    "isEstablished" BOOLEAN NOT NULL DEFAULT false,
    CONSTRAINT "VMAuth_vmId_fkey" FOREIGN KEY ("vmId") REFERENCES "VM" ("vmId") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateIndex
CREATE INDEX "VM_vmId_timestamp_idx" ON "VM"("vmId", "timestamp");

-- CreateIndex
CREATE INDEX "Metric_vmId_timestamp_idx" ON "Metric"("vmId", "timestamp");
