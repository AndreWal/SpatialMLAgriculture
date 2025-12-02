FROM rocker/geospatial:4.5.2

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libudunits2-dev \
        libv8-dev \
        libproj-dev \
        libgdal-dev \
        libcurl4-openssl-dev \
        libssl-dev \
        libxml2-dev \
        make \
        g++ \
    && rm -rf /var/lib/apt/lists/*

RUN install2.r --error --skipinstalled --ncpus -1 \
      openxlsx \
      tidymodels \
      gdalUtilities \
      exactextractr \
      elevatr \
    && rm -rf /tmp/downloaded_packages