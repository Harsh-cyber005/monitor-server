import { Request, Response } from "express";
import { prisma } from "../db/prisma";
import z from "zod";
import crypto from "crypto";

const getVMDetailsSchema = z.object({
    vmId: z.string(),
});

export interface VMDetailsPayload {
    vmId: string;
}

const createVMSchema = z.object({
    vmName: z.string(),
});

export interface CreateVMPayload {
    vmName: string;
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
    static async createVM(req: Request, res: Response): Promise<void> {
        try {
            const parsedData = createVMSchema.safeParse(req.body);
            if (!parsedData.success) {
                res.status(400).json({ error: "Please provide a valid VM name", details: parsedData.error.cause });
                return;
            }
            const data: CreateVMPayload = parsedData.data;
            const vmId = crypto.randomUUID();
            const vmSecret = crypto.randomBytes(32).toString("hex");
            const secretHash = vmSecret;
            await prisma.vM.create({
                data: {
                    vmId,
                    vmName: data.vmName,
                    ramUsedMB: 0,
                    ramTotalMB: 0,
                    cpuUsedPct: 0,
                    diskUsedMB: 0,
                    diskTotalMB: 0,
                    status: "stopped",
                    hostname: "",
                    publicIp: "",
                    timestamp: new Date(0)
                }
            });
            await prisma.vMAuth.create({
                data: {
                    vmId,
                    vmName: data.vmName,
                    secretHash,
                    isEstablished: false,
                }
            });
            res.status(201).json({
                vmId,
                vmSecret
            });
        } catch (error) {
            res.status(500).json({ error: "Internal server error", details: error });
        }
    }
}