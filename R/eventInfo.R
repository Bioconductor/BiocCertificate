# demoData <- data.frame(
#     eid = "eurobioc2023",
#     ename = "European Bioconductor 2023",
#     fullname = "Marcel Ramos Pérez"
# )

.readYmlConfig <- function() {
    edata <- system.file(
        "resources", "events.yml",
        package = "BiocCertificate", mustWork = TRUE
    )
    yaml::read_yaml(edata)
}

.filterType <- function(type) {
    edata <- .readYmlConfig()
    if (!type %in% names(edata))
        stop("<internal> 'type' not supported; contact organizers")
    edata[[type]]
}

.filterCheckEID <- function(edata, eid) {
    eid <- tolower(eid)
    if (!eid %in% names(edata))
        stop("Event ID not supported; contact organizers")
    as.data.frame(edata[[eid]])
}

eventData <- function(eid, type) {
    edata <- .filterType(type)
    edata <- .filterCheckEID(edata, eid)
    edata[["esticker"]] <- .cache_url_file(edata[["stickerdl"]])
    edata
}

.BiocCertificate_cache <- function() {
    tools::R_user_dir("BiocCertificate", "cache")
}

.get_cache <- function() {
    BiocFileCache(cache = .BiocCertificate_cache(), ask = FALSE)
}

#' @importFrom BiocFileCache BiocFileCache bfcquery bfcdownload bfcneedsupdate
#'   bfcrpath
.cache_url_file <- function(url) {
    bfc <- .get_cache()
    bquery <- bfcquery(bfc, url, "rname", exact = TRUE)
    if (identical(nrow(bquery), 1L) && bfcneedsupdate(bfc, bquery[["rid"]]))
        tryCatch({
            bfcdownload(
                x = bfc, rid = bquery[["rid"]], ask = FALSE
            )
        }, error = warning)

    bfcrpath(
        bfc, rnames = url, exact = TRUE, download = TRUE, rtype = "web"
    )
}
