export default {
    PORT_CONFIG: {
        startPort: 6000,
        endPort: 6100,
    },
    MAX_CONCURRENT_GENERATIONS: 2,

    LOCAL_PATHS: {
        python: "python",
        colmap: "D:\\Mathis\\sae\\realityclonegithub\\libs\\colmap\\bin\\colmap",
        conda: "conda",
        gaussianSplattingDirectory: "D:\\Mathis\\sae\\gaussian-splatting",
    },
    KEEP_FILES: false,
    GAUSSIAN_ENV: {
        optimized: "optimized_gaussian_splatting",
        original: "gaussian_splatting",
    }
}