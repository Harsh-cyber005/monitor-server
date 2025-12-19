import { Router, type Router as ExpressRouter } from "express";
import { VMController } from "../controllers/vm.controller";

const vmRouter : ExpressRouter = Router();

vmRouter.get("/", VMController.getVMs);

export default vmRouter;