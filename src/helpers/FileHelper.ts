import fs from 'fs';
import path from 'path';

class FileHelper {
    async getDescendantFiles(dirPath: string, extension: string): Promise<string[]> {
        let results: string[] = [];
        const files = fs.readdirSync(dirPath, { withFileTypes: true });

        for (const file of files) {
            const fullPath = path.join(dirPath, file.name);
            if (file.isDirectory()) {
                results = results.concat(await this.getDescendantFiles(fullPath, extension));
            } else if (path.extname(file.name) === extension) {
                results.push(fullPath);
            }
        }
        return results;
    }
}

export default new FileHelper();