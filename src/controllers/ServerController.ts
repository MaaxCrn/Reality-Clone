import path from "path";
import { Controller, Get, Route, Tags } from 'tsoa';


@Tags("Server")
@Route("server")
export class ServerController extends Controller {
  @Get("/ping")
  public async ping(): Promise<{ status: string; timestamp: string }> {
    return {
      status: "Server is running ✅",
      timestamp: new Date().toISOString(),
    };
  }

  @Get("/absolute-path")
  public async absolutePath(): Promise<string> {
    return path.resolve(".");
  }
}
