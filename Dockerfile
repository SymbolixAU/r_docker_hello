# Base image https://hub.docker.com/u/rocker/
FROM rocker/rstudio

## Install extra R packages using requirements.R
## Specify requirements as R install commands e.g.
## 
## install.packages("<myfavouritepacakge>") or
## devtools::install("SymbolixAU/googleway")

COPY ./DockerConfig/requirements.R /tmp/requirements.R 
RUN Rscript /tmp/requirements.R

## uncomment to include shiny server
# #RUN export ADD=shiny && bash /etc/cont-init.d/add

# create an R user
ENV USER rstudio

## Copy your working files over
COPY ./Analysis /home/$USER/Analysis
COPY ./Data /home/$USER/Data





