import AdmZip from "adm-zip";
import express from "express";
import fs from "fs";
import path from "path";
import { Controller, Post, Request, Route, Tags } from 'tsoa';
import { upload } from '../config/multer';

@Route("image")
@Tags("Image")
export class ImageController extends Controller {

  @Post("/compute-gaussian")
  public async computeGaussian(@Request() request: express.Request): Promise<{ message: string; filePath: string }> {
    const file = await this.handleFile(request);
    console.log(file);

    const extractedPath = path.join(__dirname, "../../extracted", path.basename(file.filename, ".zip"));
    try {
      // Décompresser le fichier ZIP
      const zip = new AdmZip(file.path);
      zip.extractAllTo(extractedPath, true); // Décompression dans le dossier cible
      fs.unlinkSync(file.path)

      return {
        message: "Fichier reçu avec succès !",
        filePath: extractedPath.toString(),
      };
    } catch (error) {
      console.error("Erreur lors de la décompression :", error);
      throw new Error("Impossible de décompresser le fichier.");
    }
  }

  private handleFile(request: express.Request): Promise<Express.Multer.File> {
    return new Promise((resolve, reject) => {
      upload(request, undefined as any, async (error) => {
        if (error) {
          reject(error);
        }
        resolve(request.file as Express.Multer.File);
      });
    });
  }
}
