import { Sequelize } from "sequelize";

const sequelize = new Sequelize({
    dialect: "sqlite",
    define: {
        timestamps: false,
    },
    storage: "./database.sqlite",
});

export default sequelize;