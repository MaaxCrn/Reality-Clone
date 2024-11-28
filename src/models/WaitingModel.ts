import { DataTypes, Model } from "sequelize";
import sequelize from "../config/database";
import { User } from "./User";

export interface WaitingModelAttributes {
    id?: number;
    imageDirectory: string;
    userId: number;
}

export class WaitingModel extends Model<WaitingModelAttributes> implements WaitingModelAttributes {
    public id!: number;
    public imageDirectory!: string;
    public userId!: number;

    public user?: User;
}

WaitingModel.init(
    {
        id: {
            type: DataTypes.INTEGER,
            autoIncrement: true,
            primaryKey: true,
        },
        imageDirectory: {
            type: DataTypes.STRING,
            allowNull: false,
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
        tableName: "generated_model_statuts",
    }
);

// Relation Many-to-One avec User
WaitingModel.belongsTo(User, {
    foreignKey: "userId",
    as: "user",
});