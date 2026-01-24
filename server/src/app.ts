import { WebSocketExpress } from "websocket-express";
import cors from "cors";
import prisma from "./utils/prisma.client";

// Routes
import swaggerRouter from "./routes/swagger.router";
import registerRouter from "./routes/register.router";
import loginRouter from "./routes/login.router";
import boardRouter from "./routes/board.router";
import cardRouter from "./routes/card.router";
import usersRouter from "./routes/users.router";
import boardRoomSocketRouter from "./routes/board_room.socket";

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
app.useHTTP("/api/login", loginRouter);
app.useHTTP("/api/users", usersRouter);

// Board routes
app.useHTTP("/api/boards", boardRouter);

// Card routes
app.useHTTP("/api/cards", cardRouter);

// Board WebSocket routes
app.use("/ws/boards", boardRoomSocketRouter);

// Export app for testing
export default app;

// Only start server if this file is run directly (not imported)
if (require.main === module) {
    app.listen(port, () => {
        console.log(`Backend listening on port ${port}`);
        console.log(`API docs available at http://localhost:${port}/api-docs`);
    });

    process.on("SIGINT", (): null => {
        prisma.$disconnect();
        console.log("Goodbye!");
        process.exit(0);
    });
}
