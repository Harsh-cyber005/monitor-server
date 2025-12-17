import { Router, type Router as ExpressRouter } from "express";
import { MonitorController } from "../controllers/monitor.controller";

const monitorRouter : ExpressRouter = Router();

monitorRouter.get("/", MonitorController.getStatus);
monitorRouter.post("/vm-status", MonitorController.postVMStatus);
monitorRouter.get("/vm-status", MonitorController.getVMStatuses);

export default monitorRouter;