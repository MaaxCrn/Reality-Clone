export function badRequest(description: string): never {
    const error = new Error(description);
    (error as any).status = 400;
    throw error;
}