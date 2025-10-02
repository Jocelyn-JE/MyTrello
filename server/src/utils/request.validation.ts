import { Request, Response } from "express";

export function validateJSONRequest(req: Request, res: Response) {
    console.debug("Validating JSON request");
    if (
        req.headers["content-type"] &&
        !req.headers["content-type"].includes("application/json")
    )
        return res
            .status(400)
            .json({ error: "Content-Type must be application/json" });
    if (!req.body || Object.keys(req.body).length === 0)
        return res.status(400).json({ error: "Request body is required" });
    if (typeof req.body !== "object")
        return res
            .status(400)
            .json({ error: "Request body must be valid JSON" });
    return null;
}

export function checkExactFields(
    body: Record<string, unknown>,
    res: Response,
    requiredFields: string[]
) {
    console.debug(`Checking required fields: ${requiredFields.join(", ")}`);
    const bodyKeys = Object.keys(body).sort();
    const requiredKeys = requiredFields.sort();
    if (JSON.stringify(bodyKeys) !== JSON.stringify(requiredKeys))
        return res.status(400).json({
            error:
                "Request body must contain exactly the required fields: " +
                requiredFields.join(", ")
        });
    return null;
}

export function checkAllowedFields(
    body: Record<string, unknown>,
    res: Response,
    allowedFields: string[]
) {
    console.debug(`Checking allowed fields: ${allowedFields.join(", ")}`);
    const bodyKeys = Object.keys(body).sort();
    if (bodyKeys.some((key) => !allowedFields.includes(key)))
        return res.status(400).json({
            error:
                "Request body contains invalid fields. Allowed fields are: " +
                allowedFields.join(", ")
        });
    if (bodyKeys.length === 0)
        return res.status(400).json({
            error: "Request body must contain at least one field to update."
        });
    return null;
}

// Check if any of the provided fields are empty or contain only whitespace
export function isEmpty(...fields: string[]): boolean {
    return fields.some((field) => !field || field.trim() === "");
}
