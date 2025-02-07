import { spawn } from 'child_process';
import fs from 'fs';

import AdmZip from 'adm-zip';
import path from 'path';
import portfinder from 'portfinder';
import constants from '../config/constants';
import { badRequest } from '../error/BadRequestError';
import { GeneratedModelEntity } from '../models/GeneratedModel';
import { WaitingModel } from '../models/WaitingModel';
import { colmapService } from './ColmapService';

const KEEP_FILES = false;

export class ImageService {
    public async computeGaussianForFile(file: Express.Multer.File, projectName: string, useArPositions: boolean): Promise<string> {
        await this.checkValidity();

        const extractedPath = path.join(__dirname, '../../extracted', path.basename(file.filename, '.zip'));
        const zip = new AdmZip(file.path);

        try {
            zip.extractAllTo(extractedPath, true);
            this.computeGaussianAt(extractedPath, projectName, useArPositions);

            return 'Fichier reçu avec succès !';
        } catch (error) {
            console.error('Erreur lors de la décompression :', error);
            throw new Error('Impossible de décompresser le fichier.');
        } finally {
            fs.rm(file.path, () => {
            });
        }
    }

    private async computeGaussianAt(path: string, projectName: string, useArPositions: boolean) {
        const waitingModel = await WaitingModel.create({
            imageDirectory: path,
            userId: 1,
        });

        const generationId = `${projectName}-output${waitingModel.id}`;
        const port = await portfinder.getPortPromise(constants.PORT_CONFIG);

        const colmapCommands = useArPositions ?
            colmapService.getComputeSparseFromKnownPosesCommands(path) :
            colmapService.getComputeSparseWithoutPosesCommands(path);

        console.log('Commandes Colmap :', colmapCommands);


        const query = ['activate', 'gaussian_splatting', '&&',
            ...colmapCommands,
            ' && ',
            constants.LOCAL_PATHS.python, `${constants.LOCAL_PATHS.gaussianSplattingDirectory}\\train.py`,
            `-s "${path}"`,
            `--output_directory "${generationId}"`,
            `--port ${port}`];

        const process = spawn(constants.LOCAL_PATHS.conda, query, { shell: true });


        process.stderr.on('data', (data) => {
            console.error(`Erreur : ${data.toString()}`);
        });

        process.stdout.on('data', (data) => {
            console.log(`Sortie : ${data.toString()}`);
        });

        process.on('close', (code) => {
            waitingModel.destroy();

            if (code === 0) {
                this.onGenerationSuccess(path, generationId, projectName);
            } else {
                this.onGenerationFail(generationId);
            }

            if (!KEEP_FILES) {
                fs.rm(path, { recursive: true, force: true }, () => {
                });
            }
        });
    }


    private async onGenerationSuccess(directory: string, generationId: string, projectName: string) {
        const imageDirectory = directory + '/images';
        const outputDirectory = './output/' + generationId;
        const files = fs.readdirSync(imageDirectory);
        const imagePath = `${outputDirectory}/image.${files[0].split('.').pop()}`;
        fs.renameSync(imageDirectory + '/' + files[0], imagePath);

        GeneratedModelEntity.create({
            name: projectName,
            image: imagePath,
            plyDirectory: outputDirectory,
            public: true,
            userId: 1,
            date: new Date(),
        });
    }

    private async onGenerationFail(generationId: string) {
        const outputDirectory = './output/' + generationId;

        if (!KEEP_FILES) {
            console.log('La génération a échoué, suppression du dossier de sortie.');
            fs.rm(outputDirectory, { recursive: true, force: true }, () => {
            });
        } else {
            console.log('La génération a échoué');
        }
    }

    private async checkValidity() {
        const amount = await WaitingModel.count();
        console.log(amount);

        if (amount >= constants.MAX_CONCURRENT_GENERATIONS) {
            badRequest('Il y a déjà des générations en cours');
        }
    }

    public async getGeneratedModels(): Promise<GeneratedModelEntity[]> {
        return await GeneratedModelEntity.findAll({
            where: {
                public: true,
                userId: 1,
            },
        });
    }

    public async getGeneratedModelById(id: number): Promise<GeneratedModelEntity | null> {
        return await GeneratedModelEntity.findOne({
            where: {
                id,
                userId: 1,
            },
        });
    }

    public async deleteGeneratedModelById(id: number): Promise<boolean> {
        const model = await GeneratedModelEntity.findByPk(id);

        if (model) {
            try {
                if (model.plyDirectory) {
                    const directoryPath = path.resolve(model.plyDirectory);

                    try {
                        await fs.access(directoryPath, () => {
                        });
                        await fs.rm(directoryPath, { recursive: true, force: true }, () => {
                        });
                        console.log(`Dossier ${directoryPath} supprimé.`);
                    } catch (err) {
                        console.warn(`Le dossier ${directoryPath} n'existe pas ou est déjà supprimé.`);
                    }
                }

                await model.destroy();
                return true;

            } catch (error) {
                console.error('Erreur lors de la suppression :', error);
                return false;
            }
        }

        return false;
    }


    public async getGaussianById(id: number): Promise<string | null> {

        const model = await this.getGeneratedModelById(id);
        const filePath = model?.plyDirectory;


        if (filePath != null && fs.existsSync(filePath)) {

            return filePath;
        } else {
            return null;
        }
    }

    public async addGaussian(name: string, plyDirectory: string, image: string, userId: number) {
        GeneratedModelEntity.create({
            name,
            plyDirectory,
            image,
            public: true,
            userId,
            date: new Date(),
        });
    }

}

export const imageService = new ImageService();