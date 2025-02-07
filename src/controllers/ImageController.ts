import express from "express";
import {Body, Controller, Delete, Get, Post, Request, Res, Route, Tags, TsoaResponse} from 'tsoa';
import { upload } from '../config/multer';
import { GeneratedModelDTO } from "../dto/generatedModel.dto";
import { imageService } from "../services/ImageService";
import {GeneratedModelAttributes} from "../models/GeneratedModel";


@Tags("Image")
@Route("image")
export class ImageController extends Controller {

  @Post("/compute-gaussian")
  public async computeGaussian(@Request() request: express.Request): Promise<string> {
    const file = await this.handleFile(request);

    const name = request.body.projectName as string;
    const useArPositions = request.body.useArPositions == "true";

    return imageService.computeGaussianForFile(file, name, useArPositions);
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

  @Get("/")
  public async getGeneratedModel(): Promise<GeneratedModelDTO[]> {
    return imageService.getGeneratedModels();
  }

  @Get("/{id}")
  public async getGaussianById(
    @Request() request: express.Request,
    id: number,
    @Res() response: TsoaResponse<404 | 500, { message: string }>
  ): Promise<void> {
    try {
      const filePath = await imageService.getGaussianById(id);

      if (!filePath) {
        return response(404, { message: "Fichier non trouvé" });
      }

      request.res!.setHeader("Content-Type", "application/octet-stream");
      request.res!.setHeader("Content-Disposition", `attachment; filename="gaussian_model_${id}.ply"`);

      request.res!.sendFile(filePath, (err) => {
        if (err) {
          return response(500, { message: "Erreur lors de l'envoi du fichier" });
        }
      });
    } catch (error) {
      return response(500, { message: "Erreur serveur" });
    }
  }

  @Delete("delete/{id}")
  public async deleteGeneratedModel(id: number): Promise<{ message: string }> {
    const result = await imageService.deleteGeneratedModelById(id);

    if (result) {
      return { message: `Model with ID ${id} has been deleted.` };
    } else {
      return { message: `Model with ID ${id} not found.` };
    }
  }


  @Post("/add-gaussian")
  public async addGaussian(@Body() req: GeneratedModelAttributes): Promise<string> {
    const {name, plyDirectory, image, userId}= req;
    await imageService.addGaussian(name, plyDirectory, image, userId);
    return "gg";
  }
}
