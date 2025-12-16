import { Router, type Router as ExpressRouter } from "express";
import { MonitorController } from "../controllers/monitor.controller";

const monitorRouter : ExpressRouter = Router();

monitorRouter.get("/", MonitorController.getStatus);

export default monitorRouter;