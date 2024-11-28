import fs from "fs";
import multer from "multer";
import path from "path";

export const upload = multer({
    storage: multer.diskStorage({
        destination: (req, file, cb) => {
            const uploadPath = path.join(__dirname, "../../uploads"); // Chemin du dossier de stockage
            if (!fs.existsSync(uploadPath)) {
                fs.mkdirSync(uploadPath); // Création du dossier s'il n'existe pas
            }
            cb(null, uploadPath);
        },
        filename: (req, file, cb) => {
            const uniqueSuffix = `${Date.now()}-${Math.round(Math.random() * 1e9)}`;
            cb(null, `${uniqueSuffix}-${file.originalname}`);
        },
    }),
    fileFilter: (req, file, cb) => {
        if (file.mimetype === "application/zip" || file.mimetype === "application/x-zip-compressed") {
            cb(null, true);
        } else {
            cb(new Error("Le fichier doit être au format ZIP."));
        }
    },
    limits: {
        fileSize: 1000 * 1024 * 1024, // Taille maximale : 10 Mo
    },
}).single("file"); // Un seul fichier nommé "file"
