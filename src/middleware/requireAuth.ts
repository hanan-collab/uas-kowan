import { Request, Response, NextFunction } from 'express';
import { CustomError } from './customError';
import { jwtUtils } from '../utils/jwt';

// Extend Express Request type
declare global {
    namespace Express {
        interface Request {
            user?: {
                userId: string;
                username: string;
            };
        }
    }
}

export const requireAuth = (req: Request, res: Response, next: NextFunction) => {
    // Check for token in Authorization header
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return next(new CustomError('Authentication required. Please login first.', 401));
    }

    const token = authHeader.substring(7); // Remove 'Bearer ' prefix

    const decoded = jwtUtils.verifyToken(token);

    if (!decoded) {
        return next(new CustomError('Invalid or expired token. Please login again.', 401));
    }

    // Attach user info to request
    req.user = decoded;
    next();
};