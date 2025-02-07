// src/index.ts
import express, { Application } from 'express';
import path from "path";
import { RegisterRoutes } from './routes';

import swaggerUi from "swagger-ui-express";
import errorHandler from './middlewares/errorHandler';

const app: Application = express();
const port = 3000;

app.use(express.json());
app.use(express.static("public"));
app.use(
  "/docs",
  swaggerUi.serve,
  swaggerUi.setup(undefined, {
    swaggerOptions: {
      url: "/swagger.json",
    },
  })
);

// sequelize.sync({ force: true }).then(() => {
//   User.create({ mail: "admin", password: "admin", id: 1 });
// });

RegisterRoutes(app);

app.use(errorHandler);
app.use("/static", express.static(path.resolve("./output/")));
app.listen(port, () => {
  console.log(`Server is running at http://localhost:${port}`);
});
