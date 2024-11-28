import { DataTypes, Model } from "sequelize";
import sequelize from "../config/database";

export interface UserAttributes {
    id?: number;
    mail: string;
    password: string;
}

export class User extends Model<UserAttributes> implements UserAttributes {
    public id!: number;
    public mail!: string;
    public password!: string;
}

User.init(
    {
        id: {
            type: DataTypes.INTEGER,
            autoIncrement: true,
            primaryKey: true,
        },
        mail: {
            type: DataTypes.STRING,
            allowNull: false,
            unique: true,
        },
        password: {
            type: DataTypes.STRING,
            allowNull: false,
        },
    },
    {
        sequelize,
        tableName: "users",
    }
);
