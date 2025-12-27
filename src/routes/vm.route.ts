import { Router, type Router as ExpressRouter } from "express";
import { VMController } from "../controllers/vm.controller";

const vmRouter : ExpressRouter = Router();

vmRouter.get("/", VMController.getVMs);
vmRouter.get("/:vmId", VMController.getVMDetails);
vmRouter.post("/create", VMController.createVM);

export default vmRouter;