# build on base image from https://hub.docker.com/r/rocker/shiny
FROM rocker/shiny:latest

# set working directory
WORKDIR app/

# Setup deps
RUN apt-get -y update && apt-get install -y gcc libpq-dev postgresql-client

# copy necessary files
COPY .env ./
COPY ./scripts/ app/scripts/
COPY app.R ./

# install dependencies
RUN R -e "install.packages(\"dotenv\")"
RUN R -e "install.packages(\"RPostgreSQL\")"
RUN R -e "install.packages(\"shiny\")"
RUN R -e "install.packages(\"DT\")"

# expose port
EXPOSE 3838

# run app on container start
CMD ["app/scripts/run_app.sh"]
