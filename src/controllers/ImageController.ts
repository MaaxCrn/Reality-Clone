import express from "express";
import { Controller, Post, Request, Route, Tags } from 'tsoa';
import { upload } from '../config/multer';
import { imageService } from "../services/ImageService";


@Tags("Image")
@Route("image")
export class ImageController extends Controller {

  @Post("/compute-gaussian")
  public async computeGaussian(@Request() request: express.Request): Promise<string> {
    const file = await this.handleFile(request);
    return imageService.computeGaussianForFile(file);
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
