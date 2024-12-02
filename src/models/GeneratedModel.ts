import { DataTypes, Model } from "sequelize";
import sequelize from "../config/database";

import { User } from "./User";

export interface GeneratedModelAttributes {
    id?: number;
    name: string;
    image: string;
    plyDirectory: string;
    public: boolean;
    userId: number;
}

export class GeneratedModelEntity extends Model<GeneratedModelAttributes> implements GeneratedModelAttributes {
    public id!: number;
    public name!: string;
    public image!: string;
    public plyDirectory!: string;
    public public!: boolean;
    public userId!: number;

    public user?: User;
}

GeneratedModelEntity.init(
    {
        id: {
            type: DataTypes.INTEGER,
            autoIncrement: true,
            primaryKey: true,
        },
        name: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        image: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        plyDirectory: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        public: {
            type: DataTypes.BOOLEAN,
            defaultValue: false,
        },
        userId: {
            type: DataTypes.INTEGER,
            allowNull: false,
            references: {
                model: User,
                key: "id",
            },
        },
    },
    {
        sequelize,
        tableName: "generated_model",
    }
);

// Relation Many-to-One avec User
GeneratedModelEntity.belongsTo(User, {
    foreignKey: "userId",
    as: "user",
});