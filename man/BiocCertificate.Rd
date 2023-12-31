% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/BiocCertificate.R
\name{BiocCertificate}
\alias{BiocCertificate}
\title{Generate a Bioconductor conference attendance certificate}
\usage{
BiocCertificate(...)
}
\arguments{
\item{\ldots}{Inputs to the main function are not used.}
}
\value{
Called for the side effect of displaying the shiny app.
}
\description{
The function invokes a shiny app for attendees to generate their own
certificate of attendance. This is done with the provided event identifier
(\verb{Event ID}). Attendees must enter the event identifier and their
full name in the app and click on submit. An iframe pop-up will show
the certificate along with a download / print button.
}
