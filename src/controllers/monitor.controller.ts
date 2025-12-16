import { Request, Response } from "express";

// class here with static methods give a way to namespace related functions
export class MonitorController {
    static getStatus(_req: Request, res: Response): void {
        res.status(200).json({ status: "OK", timestamp: new Date().toISOString() });
    }
}