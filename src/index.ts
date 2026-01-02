import "dotenv/config";
import express from "express";
import cors from "cors";

import monitorRouter from "./routes/monitor.route";
import vmRouter from "./routes/vm.route";
import agentRouter from "./routes/agent.route";


const app = express();
const PORT = process.env.PORT || 5000;

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

app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
    console.log(`Running in ${process.env.NODE_ENV} mode`);
});