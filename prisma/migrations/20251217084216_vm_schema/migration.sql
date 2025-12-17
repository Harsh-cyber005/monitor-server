/*
  Warnings:

  - A unique constraint covering the columns `[vmId,timestamp]` on the table `VM` will be added. If there are existing duplicate values, this will fail.

*/
-- CreateIndex
CREATE UNIQUE INDEX "VM_vmId_timestamp_key" ON "VM"("vmId", "timestamp");
