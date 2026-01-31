-- CreateEnum
CREATE TYPE "Status" AS ENUM ('running', 'stopped', 'unknown');

-- CreateTable
CREATE TABLE "VM" (
    "vmId" TEXT NOT NULL,
    "vmName" TEXT NOT NULL,
    "ramUsedMB" INTEGER NOT NULL,
    "ramTotalMB" INTEGER NOT NULL,
    "cpuUsedPct" DOUBLE PRECISION NOT NULL,
    "diskUsedMB" INTEGER NOT NULL,
    "diskTotalMB" INTEGER NOT NULL,
    "timestamp" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "hostname" TEXT NOT NULL,
    "publicIp" TEXT NOT NULL,
    "status" "Status" NOT NULL,

    CONSTRAINT "VM_pkey" PRIMARY KEY ("vmId")
);

-- CreateTable
CREATE TABLE "Metric" (
    "id" SERIAL NOT NULL,
    "vmId" TEXT NOT NULL,
    "status" "Status" NOT NULL,
    "ramUsedMB" INTEGER NOT NULL,
    "ramTotalMB" INTEGER NOT NULL,
    "cpuUsedPct" DOUBLE PRECISION NOT NULL,
    "diskUsedMB" INTEGER NOT NULL,
    "diskTotalMB" INTEGER NOT NULL,
    "timestamp" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "hostname" TEXT NOT NULL,
    "publicIp" TEXT NOT NULL,

    CONSTRAINT "Metric_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "VMAuth" (
    "vmId" TEXT NOT NULL,
    "vmName" TEXT NOT NULL,
    "secretHash" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "establishedAt" TIMESTAMP(3),
    "isEstablished" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "VMAuth_pkey" PRIMARY KEY ("vmId")
);

-- CreateTable
CREATE TABLE "Token" (
    "id" SERIAL NOT NULL,
    "token" TEXT NOT NULL,
    "vmId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "isUsed" BOOLEAN NOT NULL DEFAULT false,
    "expiresAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Token_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "VM_vmName_key" ON "VM"("vmName");

-- CreateIndex
CREATE INDEX "VM_vmId_timestamp_idx" ON "VM"("vmId", "timestamp");

-- CreateIndex
CREATE INDEX "Metric_vmId_timestamp_idx" ON "Metric"("vmId", "timestamp");

-- CreateIndex
CREATE UNIQUE INDEX "Token_token_key" ON "Token"("token");

-- AddForeignKey
ALTER TABLE "Metric" ADD CONSTRAINT "Metric_vmId_fkey" FOREIGN KEY ("vmId") REFERENCES "VM"("vmId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "VMAuth" ADD CONSTRAINT "VMAuth_vmId_fkey" FOREIGN KEY ("vmId") REFERENCES "VM"("vmId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Token" ADD CONSTRAINT "Token_vmId_fkey" FOREIGN KEY ("vmId") REFERENCES "VM"("vmId") ON DELETE CASCADE ON UPDATE CASCADE;
