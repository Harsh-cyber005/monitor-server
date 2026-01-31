import { Router, type Router as ExpressRouter } from "express";
import { MonitorController } from "../controllers/monitor.controller";
import { moniterAuthMiddleware } from "../middlewares/monitorAuth.middleware";

const monitorRouter : ExpressRouter = Router();

monitorRouter.get("/", MonitorController.getStatus);
monitorRouter.post("/vm-status", moniterAuthMiddleware, MonitorController.postMetric);
monitorRouter.get("/vm-status", MonitorController.getVMMetrics);

export default monitorRouter;