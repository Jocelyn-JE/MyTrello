import { Router } from "websocket-express";
import fs from "fs";
import path from "path";
import yaml from "yaml";
import swaggerUi from "swagger-ui-express";
import { Request, Response, NextFunction } from "express";

const filePath = path.join(__dirname, "../../../docs/swagger.yaml");
const router = new Router();

declare global {
    // eslint-disable-next-line @typescript-eslint/no-namespace
    namespace Express {
        interface Request {
            swaggerDoc?: swaggerUi.JsonObject;
        }
    }
}

// Reads and parses the swagger file
function getSwaggerConfigFile(): swaggerUi.JsonObject {
    const file = fs.readFileSync(filePath, "utf8");
    console.log("Swagger file loaded");
    return yaml.parse(file);
}

const swaggerOptions = {
    explorer: true,
    customCss: ".swagger-ui .topbar { display: none }",
    customSiteTitle: "MyTrello API Documentation"
};

// Middleware to attach the swagger file to the request
function middleware(req: Request, res: Response, next: NextFunction) {
    /* c8 ignore next */
    if (req.path !== "/") return next();
    req.swaggerDoc = getSwaggerConfigFile();
    next();
}

// Endpoint to get the raw swagger JSON
router.get("/swagger.json", (req, res) => {
    res.json(getSwaggerConfigFile());
});

// Reloads and serves the swagger file on each request
router.useHTTP(
    "/",
    middleware,
    swaggerUi.serve,
    swaggerUi.setup(undefined, swaggerOptions)
);

export default router;
