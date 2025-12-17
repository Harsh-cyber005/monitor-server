import "dotenv/config";
import express from "express";

import monitorRouter from "./routes/monitor.route";


const app = express();
const PORT = process.env.PORT || 5000;

app.use(express.json());

app.use("/monitor", monitorRouter);

app.get("/", (_req, res) => {
    res.send("Hello, World!");
});

app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});