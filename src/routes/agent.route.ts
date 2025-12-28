import { Router, type Router as ExpressRouter } from "express";
import { AgentController } from "../controllers/agent.controller";

const agentRouter: ExpressRouter = Router();

agentRouter.get("/setup.sh", AgentController.getSetupScript);

export default agentRouter;