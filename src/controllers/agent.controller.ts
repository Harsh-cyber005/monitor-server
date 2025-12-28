import { Request, Response } from "express";
import { prisma } from "../db/prisma";
import path from "path";
import fs from "fs/promises";

async function generateScript(vmId: string, secretHash: string): Promise<string> {
    const scriptPath = path.join(__dirname, "../../scripts/setup-agent.sh");
    let scriptContent = await fs.readFile(scriptPath, "utf-8");
    scriptContent = scriptContent.replace(/{{VM_ID}}/g, vmId);
    scriptContent = scriptContent.replace(/{{VM_SECRET}}/g, secretHash);
    return scriptContent;
}

export class AgentController {
    static async getSetupScript(req: Request, res: Response): Promise<void> {
        const token = req.query.token;
        if (typeof token !== "string" || token.trim() === "") {
            res.status(400).send("Invalid or missing token");
            return;
        }
        const installToken = await prisma.token.findUnique({
            where: { token: token }
        });
        if (!installToken || installToken.expiresAt < new Date()) {
            res.status(400).send("Invalid or expired token");
            return;
        }
        if (installToken.isUsed) {
            res.status(400).send("Token has already been used");
            return;
        }
        await prisma.token.update({
            where: { token: token },
            data: { isUsed: true }
        });
        const vmAuth = await prisma.vMAuth.findUnique({
            where: { vmId: installToken.vmId }
        });
        if (!vmAuth) {
            res.status(500).send("Associated VM not found");
            return;
        }
        const setupScript = await generateScript(vmAuth.vmId, vmAuth.secretHash);
        res.setHeader("Content-Type", "text/x-shellscript");
        res.status(200).send(setupScript);
    }
};