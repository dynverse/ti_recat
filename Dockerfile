FROM dynverse/dynwrap:r

LABEL version 0.1.0.1

RUN R -e 'devtools::install_github("dynverse/reCAT")'

ADD . /code

ENTRYPOINT /code/run.sh