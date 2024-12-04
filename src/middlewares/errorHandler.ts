import { NextFunction, Request, Response } from "express";

// Interface pour les erreurs
interface Error {
    status?: number;
    message?: string;
}

// Middleware pour gérer les erreurs
const errorHandler = (
    err: Error,
    req: Request,
    res: Response,
    next: NextFunction
): void => {
    console.log("Test");
    console.error("An error occurred:", err);

    // Définir un statut d'erreur par défaut
    const statusCode = err.status || 500;
    const message = statusCode === 400 ? "Invalid Request" : err.message || "Internal Server Error";

    // Envoyer la réponse d'erreur au client
    res.status(statusCode).json({
        status: statusCode,
        message: message,
    });
};

export default errorHandler;