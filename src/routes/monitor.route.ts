import { Router, type Router as ExpressRouter } from "express";

const monitorRouter : ExpressRouter = Router();

monitorRouter.get("/", (_req, res) => {
    res.send("Monitor Route is working!");
});

export default monitorRouter;