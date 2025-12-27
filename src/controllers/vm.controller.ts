import { Request, Response } from "express";
import { prisma } from "../db/prisma";
import z from "zod";

const getVMDetailsSchema = z.object({
    vmId: z.string(),
});

export interface VMDetailsPayload {
    vmId: string;
}

export class VMController {
    static async getVMs(_req: Request, res: Response): Promise<void> {
        try {
            await prisma.vM.updateMany({
                data: {
                    status: "stopped"
                },
                where: {
                    timestamp: {
                        lt: new Date(Date.now() - 3 * 60 * 1000) // 3 minutes ago
                    }
                }
            });
            const vms = await prisma.vM.findMany({
                select: {
                    vmId: true,
                    vmName: true,
                    ramUsedMB: true,
                    ramTotalMB: true,
                    cpuUsedPct: true,
                    status: true,
                    diskUsedMB: true,
                    diskTotalMB: true,
                    hostname: true,
                    publicIp: true,
                    timestamp: true
                }
            });
            res.status(200).json(vms);
        } catch (error) {
            res.status(500).json({ error: "Internal server error", details: error });
            return;
        }
    }
    static async getVMDetails(req: Request, res: Response): Promise<void> {
        try {
            const parsedData = getVMDetailsSchema.safeParse(req.params);
            if (!parsedData.success) {
                res.status(400).json({ error: "Invalid VM ID", details: parsedData.error.cause });
                return;
            }
            const data: VMDetailsPayload = parsedData.data;
            const vm = await prisma.vM.findUnique({
                where: { vmId: data.vmId },
                select: {
                    vmId: true,
                    vmName: true,
                    ramUsedMB: true,
                    ramTotalMB: true,
                    cpuUsedPct: true,
                    status: true,
                    diskUsedMB: true,
                    diskTotalMB: true,
                    hostname: true,
                    publicIp: true,
                    timestamp: true
                }
            });
            if (!vm) {
                res.status(404).json({ error: "VM not found" });
                return;
            }
            res.status(200).json(vm);
        } catch (error) {
            res.status(500).json({ error: "Internal server error", details: error });
        }
    }
}