export const rpName: string = 'Passkeys Tutorial';
export const rpID: string = process.env.RP_ID || 'localhost';
export const origin: string = process.env.ORIGIN || `http://${rpID}:8080`;
