import { spawn } from "child_process";
import fs from 'fs';

import AdmZip from "adm-zip";
import path from "path";
import portfinder from "portfinder";
import constants from "../config/constants";
import { badRequest } from "../error/BadRequestError";
import { GeneratedModelEntity } from "../models/GeneratedModel";
import { WaitingModel } from "../models/WaitingModel";

export class ImageService {
    public async computeGaussianForFile(file: Express.Multer.File) {
        await this.checkValidity();

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
        const port = await portfinder.getPortPromise(constants.PORT_CONFIG);

        const query = ["activate", "gaussian_splatting", "&&",
            "python", "D:\\Mathis\\sae\\gaussian-splatting\\train.py -s", path,
            "--output_directory", generationId,
            "--port", port.toString()];

        const process = spawn("conda", query, { shell: true });


        process.stderr.on("data", (data) => {
            console.error(`Erreur : ${data.toString()}`);
        });

        process.stdout.on("data", (data) => {
            console.log(`Sortie : ${data.toString()}`);
        });

        process.on("close", (code) => {
            waitingModel.destroy();
            fs.rm(path, { recursive: true, force: true }, () => { });

            if (code === 0) {
                this.onGenerationSuccess(path, generationId);
            } else {
                this.onGenerationFail(generationId);
            }
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

    private async onGenerationFail(generationId: string) {
        const outputDirectory = "./output/" + generationId;
        console.log("La génération a échoué, suppression du dossier de sortie.");

        fs.rm(outputDirectory, { recursive: true, force: true }, () => { });
    }

    private async checkValidity() {
        const amount = await WaitingModel.count();
        console.log(amount);

        if (amount >= constants.MAX_CONCURRENT_GENERATIONS) {
            badRequest("Il y a déjà des générations en cours")
        }
    }
}

export const imageService = new ImageService();