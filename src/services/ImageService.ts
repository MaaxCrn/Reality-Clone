import { spawn } from "child_process";
import fs from 'fs';

import AdmZip from "adm-zip";
import path from "path";

export class ImageService {
    public async computeGaussianForFile(file: Express.Multer.File) {
        const extractedPath = path.join(__dirname, "../../extracted", path.basename(file.filename, ".zip"));
        try {
            // Décompresser le fichier ZIP
            const zip = new AdmZip(file.path);
            zip.extractAllTo(extractedPath, true); // Décompression dans le dossier cible
            fs.unlink(file.path, () => { })

            this.computeGaussianAt(extractedPath);

            return "Fichier reçu avec succès !"
        } catch (error) {
            console.error("Erreur lors de la décompression :", error);
            throw new Error("Impossible de décompresser le fichier.");
        }
    }

    private computeGaussianAt(path: string) {
        const command = "conda";
        const args = ["activate", "gaussian_splatting", "&&", "python", "gaussian_splatting.py", path];

        const process = spawn(command, args, { shell: true });

        process.stdout.on("data", (data) => {
            console.log(`Sortie : ${data.toString()}`);
        });

        process.stderr.on("data", (data) => {
            console.error(`Erreur : ${data.toString()}`);
        });

        process.on("close", (code) => {
            fs.rm(path, { recursive: true, force: true }, () => { });

            if (code === 0) {
                console.log("Exécution réussie !");
            } else {
                console.error("Le processus a rencontré une erreur.");
            }
        });
    }
}

export const imageService = new ImageService();