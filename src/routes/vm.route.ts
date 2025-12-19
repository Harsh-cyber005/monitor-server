import { Router, type Router as ExpressRouter } from "express";
import { VMController } from "../controllers/vm.controller";

const vmRouter : ExpressRouter = Router();

vmRouter.get("/", VMController.getVMs);
vmRouter.get("/:vmId", VMController.getVMDetails);

// export interface VMDetailsPayload {
//     vmId: string;
// }

export default vmRouter;