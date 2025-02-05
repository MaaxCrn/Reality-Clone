import constants from '../config/constants';

export class ColmapService {
    private colmap = constants.LOCAL_PATHS.colmap;


    private getExtractFeaturesCommand(databasePath: string, imagesPath: string): string {
        return `${this.colmap} feature_extractor` +
                    ` --database_path "${databasePath}"`+
                    ` --image_path "${imagesPath}"`+
                    ` --ImageReader.camera_model PINHOLE`+
                    ` --ImageReader.single_camera 1`;
    }


    private getMatchFeaturesCommand(databasePath: string, optimizeForVideo: boolean = false): string {
        return optimizeForVideo ?
            `${this.colmap} sequential_matcher --database_path "${databasePath}"`:
            `${this.colmap} exhaustive_matcher --database_path "${databasePath}"`;
    }

    private getTriangulatePointsCommand(databasePath: string, imagesPath: string, sparsePath: string, allowRefineCameraIntrinsics: boolean = true): string {
        let command = `${this.colmap} mapper` +
                                ` --database_path "${databasePath}"` +
                                ` --image_path "${imagesPath}"` +
                                ` --output_path "${sparsePath}"`;

        if (!allowRefineCameraIntrinsics) {
            command +=  ` --Mapper.ba_refine_focal_length 0` +
                        ` --Mapper.ba_refine_principal_point 0` +
                        ` --Mapper.ba_refine_extra_params 0`;
        }
        return command;
    }


    public getComputeSparseFromKnownPosesCommands(extractedFilePath: string): string[] {
        const imagePath = `${extractedFilePath}\\images`;
        const dbPath = `${extractedFilePath}\\database.db`;

        //extract features to database
        const step1 = this.getExtractFeaturesCommand(dbPath, imagePath);

        //match features
        const step2 = this.getMatchFeaturesCommand(dbPath);

        //triangulate points
        const step3 = this.getTriangulatePointsCommand(dbPath, imagePath, `${extractedFilePath}\\sparse`, false);

        return [step1, '&&', step2, '&&', step3];
    }


    public getComputeSparseWithoutPosesCommands(extractedFilePath: string): string[] {
        const imagePath = `${extractedFilePath}\\images`;
        const dbPath = `${extractedFilePath}\\database.db`;
        const sparsePath = `${extractedFilePath}\\sparse`;

        //create sparse folder
        const step1 = `mkdir ${sparsePath}`;

        //extract features to database
        const step2 = this.getExtractFeaturesCommand(dbPath, imagePath);

        //match features
        const step3 = this.getMatchFeaturesCommand(dbPath, true);

        //triangulate points
        const step4 = this.getTriangulatePointsCommand(dbPath, imagePath, sparsePath, true);

        return [step1, '&&', step2, '&&', step3, '&&', step4];
    }

}

export const colmapService = new ColmapService();