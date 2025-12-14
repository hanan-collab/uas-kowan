export const circleService = {
    calculateArea(radius: number): number {
        if (radius < 0) {
            throw new Error('Radius cannot be negative');
        }
        return Math.PI * radius * radius;
    },

    calculateCircumference(radius: number): number {
        if (radius < 0) {
            throw new Error('Radius cannot be negative');
        }
        return 2 * Math.PI * radius;
    },

    calculateBoth(radius: number): { area: number; circumference: number } {
        return {
            area: this.calculateArea(radius),
            circumference: this.calculateCircumference(radius)
        };
    }
};