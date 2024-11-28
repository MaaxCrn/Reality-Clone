import { Sequelize } from "sequelize";

const sequelize = new Sequelize({
    dialect: "sqlite",
    define: {
        timestamps: false,
    },
    storage: "./game.sqlite", // Chemin vers la base SQLite
});

export default sequelize;