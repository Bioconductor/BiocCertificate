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

.filterCheckEID <- function(edata, eid) {
    eid <- tolower(eid)
    if (!eid %in% names(edata[["events"]]))
        stop("Event ID not supported; contact organizers")
    as.data.frame(edata[["events"]][[eid]])
}

eventData <- function(eid) {
    edata <- .readYmlConfig()
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

.getEname <- function(key) {
    edata <- .readYmlConfig()
    edata <- .filterCheckEID(edata, key)
    edata[["ename"]]
}

.genEurl <- function(key) {
    eurl <- paste0("https://", key, ".bioconductor.org")
    if (!crul::ok(eurl))
        stop("Event URL does not exist or not available; check 'key'")
    eurl
}
