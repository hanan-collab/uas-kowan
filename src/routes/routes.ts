import express from 'express';
import { handleError } from '../middleware/errorHandler';
import { handleRegisterStart, handleRegisterFinish } from '../controllers/registration';
import { handleLoginStart, handleLoginFinish } from '../controllers/authentication';
import { handleCircleCalculation } from '../controllers/circle';
import { requireAuth } from '../middleware/requireAuth';

const router = express.Router();

router.post('/registerStart', handleRegisterStart);
router.post('/registerFinish', handleRegisterFinish);
router.post('/loginStart', handleLoginStart);
router.post('/loginFinish', handleLoginFinish);

// Proteksi route circle dengan requireAuth middleware
router.post('/circle/calculate', requireAuth, handleCircleCalculation);

router.use(handleError);

export { router };