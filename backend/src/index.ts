import "dotenv/config";
import express from "express";
import cors from "cors";
import cron from "node-cron";

import monitorRouter from "./routes/monitor.route";
import vmRouter from "./routes/vm.route";
import agentRouter from "./routes/agent.route";
import { cleanupOldRecords } from "./jobs/cleanup/cleanup.job";


const app = express();
const PORT = Number(process.env.PORT) || 5000;

app.use(cors({
    origin: "*",
    methods: ["GET", "POST", "PUT", "DELETE", "PATCH"],
}));
app.use(express.json());

app.use("/monitor", monitorRouter);
app.use("/vm", vmRouter);
app.use("/agent", agentRouter);

app.get("/", (_req, res) => {
    res.send("Hello, World!");
});

cron.schedule('0 0 * * *', async () => {
    console.log("[CRON] Running Midnight Database Cleanup...");
    await cleanupOldRecords();
});

app.listen(PORT, "0.0.0.0", () => {
    console.log(`Server is running on port ${PORT}`);
    console.log(`Running in ${process.env.NODE_ENV} mode`);
});
