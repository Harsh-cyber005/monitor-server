import { Request, Response, NextFunction } from "express";
import { postVMStatusSchema } from "../controllers/monitor.controller";
import crypto from "crypto";
import { prisma } from "../db/prisma";

const MAX_SKEW_MS = 2 * 60 * 1000;

export async function moniterAuthMiddleware(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
        const parsedData = postVMStatusSchema.safeParse(req.body);
        if (!parsedData.success) {
            res.status(400).json({ error: "Invalid payload", details: parsedData.error.cause });
            return;
        }
        const data = parsedData.data;
        const vmAuth = await prisma.vMAuth.findUnique({
            where: { vmId: data.vmId }
        });
        if (!vmAuth) {
            res.status(401).json({ error: "Authentication failed: Unknown VM ID" });
            return;
        }
        if ( vmAuth.isEstablished === false && Date.now() - vmAuth.createdAt.getTime() > 24 * 60 * 60 * 1000 ) {
            res.status(401).json({ error: "Authentication failed: VM not established within 24 hours" });
            return;
        }
        const ts = Date.parse(data.timestamp);
        if (isNaN(ts)) {
            res.status(400).json({ error: "Invalid timestamp" });
            return;
        }
        if (Math.abs(Date.now() - ts) > MAX_SKEW_MS) {
            res.status(400).json({ error: "Timestamp outside allowed window" });
            return;
        }
        const payload = `${data.vmId}|${data.timestamp}`;
        const expectedSignature = crypto
            .createHmac("sha256", vmAuth.secretHash)
            .update(payload)
            .digest("hex");
        const sigBuffer = Buffer.from(data.signature, "hex");
        const expectedSigBuffer = Buffer.from(expectedSignature, "hex");
        if (sigBuffer.length !== expectedSigBuffer.length) {
            res.status(401).json({ error: "Authentication failed: Invalid signature length" });
            return;
        } else if (!crypto.timingSafeEqual(sigBuffer, expectedSigBuffer)) {
            res.status(401).json({ error: "Authentication failed: Invalid signature" });
            return;
        }
        next();
    } catch (error) {
        console.error("Authentication error:", error);
        res.status(500).json({ error: "Internal server error", details: error });
    }
}