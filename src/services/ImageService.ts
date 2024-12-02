import { spawn } from "child_process";
import fs from 'fs';

import AdmZip from "adm-zip";
import path from "path";
import { GeneratedModelEntity } from "../models/GeneratedModel";
import { WaitingModel } from "../models/WaitingModel";

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

    private async computeGaussianAt(path: string) {
        const waitingModel = await WaitingModel.create({
            imageDirectory: path,
            userId: 1
        });
        const generationId = "output" + waitingModel.id.toString();
        const query = ["activate", "gaussian_splatting", "&&",
            "python", "D:\\Mathis\\sae\\gaussian-splatting\\train.py -s", path,
            "--output_directory", generationId];

        const process = spawn("conda", query, { shell: true });


        process.stderr.on("data", (data) => {
            console.error(`Erreur : ${data.toString()}`);
        });

        process.stdout.on("data", (data) => {
            console.log(`Sortie : ${data.toString()}`);
        });

        process.on("close", (code) => {
            if (code === 0) {
                this.onGenerationSuccess(path, generationId);
            } else {
                console.error("Le processus a rencontré une erreur.");
            }

            fs.rm(path, { recursive: true, force: true }, () => { });
            waitingModel.destroy();
        });
    }

    private async onGenerationSuccess(directory: string, generationId: string) {
        const imageDirectory = directory + "/images";
        const outputDirectory = "./output/" + generationId;
        const files = fs.readdirSync(imageDirectory);
        const imagePath = `${outputDirectory}/image.${files[0].split(".").pop()}`
        fs.renameSync(imageDirectory + "/" + files[0], imagePath);

        GeneratedModelEntity.create({
            name: directory.split("-").pop() || "Inconnu",
            image: imagePath,
            plyDirectory: outputDirectory,
            public: true,
            userId: 1
        });
    }

}

export const imageService = new ImageService();