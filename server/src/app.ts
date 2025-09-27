import { WebSocketExpress } from "websocket-express";
import cors from "cors";
import prisma from "./utils/prisma.client";

// Routes
import swaggerRouter from "./routes/swagger.router";
import registerRouter from "./routes/register.router";

const app = new WebSocketExpress();
const port = 3000;

app.use(cors());
app.use(WebSocketExpress.json());
app.use(WebSocketExpress.urlencoded({ extended: true }));

// Test route
app.get("/", (req, res) => {
    res.send("Server is running");
});

// Documentation route
app.useHTTP("/api-docs", swaggerRouter);

// User routes
app.useHTTP("/api/register", registerRouter);

// Export app for testing
export default app;

// Only start server if this file is run directly (not imported)
if (require.main === module) {
    app.listen(port, () => {
        console.log(`Backend listening on port ${port}`);
    });

    process.on("SIGINT", (): null => {
        prisma.$disconnect();
        console.log("Goodbye!");
        process.exit(0);
    });
}
