# Launch the ShinyApp (Do not remove this comment)

if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

options(repos = BiocManager::repositories())

if (!requireNamespace("BiocCertificate", quietly = TRUE))
    BiocManager::install("Bioconductor/BiocCertificate")

BiocCertificate::BiocCertificate()

