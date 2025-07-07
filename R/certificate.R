templatePath <- function(file = c("certificate", "letter", "workshop")) {
    file <- match.arg(file)
    filename <- switch(
        file,
        certificate = "CertificateTemplate.txt",
        letter = "LetterTemplate.txt",
        workshop = "WorkshopTemplate.txt"
    )
    system.file(
        "resources", filename, package = "BiocCertificate", mustWork = TRUE
    )
}

.checkData <- function(data) {
    dataok <- all(.MANDATORY_DATA_NAMES %in% names(data))
    if (!dataok)
        stop(
            "<internal> 'data' does not have required column names"
        )
    manData <- data[, .MANDATORY_DATA_NAMES]
    datavalid <- vapply(
        manData, function(x) BiocBaseUtils::isScalarCharacter(x), logical(1L)
    )
    if (!all(datavalid))
        stop("Columns do not have valid data: ", names(manData)[!datavalid])
    TRUE
}

.growData <- function(.data, type) {
    ## TODO: auto fill based on Event ID
    eid <- .data[["eid"]]
    edf <- eventData(eid, type)
    elogo <- system.file(
        "images", "bioconductor_logo_rgb.png",
        package = "BiocCertificate", mustWork = TRUE
    )
    biocseal <- system.file(
        "images", "Bioconductor.png",
        package = "BiocCertificate", mustWork = TRUE
    )
    cbind.data.frame(.data, edf, bioclogo = elogo, biocseal = biocseal)
}

.preprocessData <- function(.data) {
    if (length(.data[["address"]]))
        .data[["address"]] <-
            gsub("\n", "\\\\", .data[["address"]], fixed = TRUE)
    if (length(.data[["eurl"]]))
        .data[["eurl"]] <- paste0("\\url{", .data[["eurl"]], "}")
    .data
}

certificate <- function(template = "certificate", .data, file) {
    stub <- basename(file)
    .data <- .growData(.data, template)
    .data <- .preprocessData(.data)
    .checkData(.data)
    template <- templatePath(template)
    templateCert <- readLines(template)
    tmpRmd <- whisker::whisker.render(
        templateCert,
        data = .data
    )
    RmdFile <- tempfile(fileext = ".Rmd")
    writeLines(tmpRmd, RmdFile)
    rmarkdown::render(
        input = RmdFile, output_file = file, quiet = TRUE, clean = FALSE
    )
    file.path("temp", stub)
}
