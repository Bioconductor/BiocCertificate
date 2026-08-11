FROM ghcr.io/bioconductor/shiny:devel AS build

RUN chown -R shiny /usr/local/lib/R/site-library && \
    chown -R shiny /usr/local/lib/R/library && \
    rm -rf /srv/shiny-server/sample-apps && \
    curl -fsSL -o /srv/shiny-server/index.html \
    https://gist.githubusercontent.com/almahmoud/58261d03bfb342274f2e642c4b2ebc4d/raw/4e0271990bce57ae091f622db47b15f8fd89fa29/index.html && \
    mkdir -p /srv/shiny-server/biocshiny && \
    sed -i '/^run_as shiny;/a app_init_timeout 300;\napp_idle_timeout 300;' \
    /etc/shiny-server/shiny-server.conf && \
    grep -q '^app_init_timeout 300;' /etc/shiny-server/shiny-server.conf

RUN Rscript -e "options(repos = c(CRAN = 'https://p3m.dev/cran/__linux__/noble/latest')); \
    install.packages(c('remotes', 'BiocManager'))"

COPY --chown=shiny:shiny . /tmp/repo/

USER shiny

RUN cd /tmp/repo && \
    Rscript -e "options(repos = c(CRAN = 'https://p3m.dev/cran/__linux__/noble/latest')); \
    BiocManager::install(ask=FALSE)" && \
    Rscript -e "options(repos = c(CRAN = 'https://p3m.dev/cran/__linux__/noble/latest')); \
    remotes::install_local(dependencies=TRUE, build_vignettes=TRUE, repos = BiocManager::repositories()); \
    tinytex::install_tinytex()" && \
    rm -rf /tmp/repo

COPY --chown=shiny:shiny app.R /srv/shiny-server/biocshiny/app.R

USER root
