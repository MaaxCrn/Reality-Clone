export function notfound(description: string): never {
    const error = new Error(description);
    (error as any).status = 404;
    throw error;
}