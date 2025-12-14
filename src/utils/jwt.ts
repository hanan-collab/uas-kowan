import jwt from 'jsonwebtoken';

const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key-change-in-production';
const JWT_EXPIRES_IN = '24h';

export const jwtUtils = {
    generateToken(userId: string, username: string): string {
        return jwt.sign(
            { userId, username },
            JWT_SECRET,
            { expiresIn: JWT_EXPIRES_IN }
        );
    },

    verifyToken(token: string): { userId: string; username: string } | null {
        try {
            const decoded = jwt.verify(token, JWT_SECRET) as { userId: string; username: string };
            return decoded;
        } catch (error) {
            return null;
        }
    }
};
