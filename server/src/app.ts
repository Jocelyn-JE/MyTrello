import { WebSocketExpress } from "websocket-express";
import cors from "cors";

// Routes
import swaggerRouter from "./routes/swagger.router";

const app = new WebSocketExpress();
const port = process.env.PORT || 3000;

app.use(cors());
app.use(WebSocketExpress.json());
app.use(WebSocketExpress.urlencoded({ extended: true }));

// Test route
app.get("/", (req, res) => {
    res.send("Server is working");
});

// Documentation route
app.useHTTP("/api-docs", swaggerRouter);

app.listen(port, () => {
    console.log(`Backend listening on port ${port}`);
});

process.on("SIGINT", (): null => {
    console.log("Goodbye!");
    process.exit(0);
});

export default app;
