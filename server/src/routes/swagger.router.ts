import { Router } from "websocket-express";
import fs from "fs";
import path from "path";
import yaml from "yaml";
import swaggerUi from "swagger-ui-express";

const filePath = path.join(__dirname, "../../../docs/swagger.yaml");
const router = new Router();

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
function middleware(req: any, res: any, next: any) {
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
