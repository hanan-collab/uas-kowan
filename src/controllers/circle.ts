import { Request, Response, NextFunction } from 'express';
import { circleService } from '../services/circleService';
import { CustomError } from '../middleware/customError';

export const handleCircleCalculation = async (req: Request, res: Response, next: NextFunction) => {
    const { radius } = req.body;
    const user = req.user; // From requireAuth middleware

    if (!radius || isNaN(radius) || radius <= 0) {
        return next(new CustomError('Valid radius is required', 400));
    }

    try {
        const result = circleService.calculateBoth(parseFloat(radius));
        res.json({
            radius: parseFloat(radius),
            area: result.area.toFixed(2),
            circumference: result.circumference.toFixed(2),
            calculatedBy: user?.username
        });
    } catch (error) {
        next(error instanceof CustomError ? error : new CustomError('Internal Server Error', 500));
    }
};