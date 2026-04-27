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

.escapeLatex <- function(x) {
    if (!is.character(x))
        stop(
            "<internal> field must be a character vector, got: ", class(x)
        )

    x <- iconv(x, from = "UTF-8", to = "UTF-8", sub = "byte") |>
        gsub("\\\\", "\\\\textbackslash{}", x = _, perl = TRUE) |>
        gsub("([&%$#_{}])", "\\\\\\1", x = _, perl = TRUE) |>
        gsub("~", "\\\\textasciitilde{}",  x = _, perl = TRUE) |>
        gsub("\\^", "\\\\textasciicircum{}", x = _, perl = TRUE) |>
        gsub("\\[", "{[}", x = _, perl = TRUE) |>
        gsub("\\]", "{]}", x = _, perl = TRUE) |>
        gsub("[[:cntrl:]]", "", x = _, perl = TRUE)

    max_chars <- 500L
    if (any(nchar(x) > max_chars)) {
        warning(
            "Input exceeded length of ", max_chars, " characters; truncating..."
        )
        x <- substr(x, 1L, max_chars)
    }
    x
}

.preprocessData <- function(.data) {
    .data[["fullname"]] <- .escapeLatex(.data[["fullname"]])
    if (length(.data[["address"]])) {

        .data[["address"]] <-
            gsub("\n", "\\\\", .data[["address"]], fixed = TRUE)
    }
    if (length(.data[["eurl"]]))
        .data[["eurl"]] <- paste0("\\url{", .data[["eurl"]], "}")
    .data
}

certificate <- function(template = "certificate", .data, file) {
    stub <- basename(file)
    type <- switch(
        template,
        letter =,
        certificate = "conference",
        workshop = "workshop"
    )
    .data <- .growData(.data, type)
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
