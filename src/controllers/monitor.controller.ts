import { Request, Response } from "express";
import { prisma } from "../db/prisma";
import z from "zod";

export interface postVMStatusPayload {
    vmId: string;
    status: "running" | "stopped" | "error";
    timestamp: string;
    ramUsedMB: number;
    ramTotalMB: number;
    diskUsedMB: number;
    diskTotalMB: number;
    cpuUsed: number;
    hostname: string;
    publicIp: string;
};

const postVMStatusSchema = z.object({
    vmId: z.string().nonempty(),
    status: z.enum(["running", "stopped", "error"]),
    timestamp: z.string().refine((date) => !isNaN(Date.parse(date)), { message: "Invalid date format" }),
    ramUsedMB: z.number().nonnegative(),
    ramTotalMB: z.number().positive(),
    diskUsedMB: z.number().nonnegative(),
    diskTotalMB: z.number().positive(),
    cpuUsed: z.number().min(0).max(100),
    hostname: z.string().nonempty(),
    publicIp: z.string()
});

export interface getVMStatusesQuery {
    vmId: string;
    limit?: number;
}

const getVMStatusesQuerySchema = z.object({
    vmId: z.string().nonempty(),
    limit: z.number().optional()
});

// class here with static methods give a way to namespace related functions
export class MonitorController {
    static getStatus(_req: Request, res: Response): void {
        res.status(200).json({ status: "OK", timestamp: new Date().toISOString() });
    }

    static async postMetric(req: Request, res: Response): Promise<void> {
        try {
            const parsedData = postVMStatusSchema.safeParse(req.body);
            if (!parsedData.success) {
                res.status(400).json({ error: "Invalid payload", details: parsedData.error.cause });
                return;
            }
            const data: postVMStatusPayload = parsedData.data;
            await prisma.vM.upsert({
                where: { vmId: data.vmId },
                update: {
                    status: data.status,
                    hostname: data.hostname,
                    publicIp: data.publicIp,
                    timestamp: new Date(data.timestamp),
                    ramUsedMB: data.ramUsedMB,
                    ramTotalMB: data.ramTotalMB,
                    diskUsedMB: data.diskUsedMB,
                    diskTotalMB: data.diskTotalMB,
                    cpuUsedPct: data.cpuUsed
                },
                create: {
                    vmId: data.vmId,
                    status: data.status,
                    hostname: data.hostname,
                    publicIp: data.publicIp,
                    timestamp: new Date(data.timestamp),
                    ramUsedMB: data.ramUsedMB,
                    ramTotalMB: data.ramTotalMB,
                    diskUsedMB: data.diskUsedMB,
                    diskTotalMB: data.diskTotalMB,
                    cpuUsedPct: data.cpuUsed
                }
            });
            await prisma.metric.create({
                data: {
                    vmId: data.vmId,
                    status: data.status,
                    timestamp: new Date(data.timestamp),
                    ramUsedMB: data.ramUsedMB,
                    ramTotalMB: data.ramTotalMB,
                    diskUsedMB: data.diskUsedMB,
                    diskTotalMB: data.diskTotalMB,
                    cpuUsedPct: data.cpuUsed,
                    hostname: data.hostname,
                    publicIp: data.publicIp
                }
            });
            res.status(201).json({ message: "VM status recorded successfully" });
        } catch (error) {
            res.status(500).json({ error: "Internal server error", details: error });
            return;
        }
    }

    static async getVMMetrics(_req: Request, res: Response): Promise<void> {
        try {
            const parsedQuery = getVMStatusesQuerySchema.safeParse(_req.body);
            if (!parsedQuery.success) {
                res.status(400).json({ error: "Invalid query parameters", details: parsedQuery.error.cause });
                return;
            }
            const query: getVMStatusesQuery = parsedQuery.data;
            if (!query.limit) {
                query.limit = 10;
            }
            if (query.limit < 1 || query.limit > 100) {
                res.status(400).json({ error: "Limit must be between 1 and 100" });
                return;
            }
            const vmStatuses = await prisma.vM.findMany({
                where: { vmId: query.vmId },
                orderBy: { timestamp: "desc" },
                take: query.limit
            });
            res.status(200).json({ vmStatuses });
        } catch (error) {
            res.status(500).json({ error: "Internal server error", details: error });
            return;
        }
    }
}