FROM nvcr.io/nvidia/rapidsai/rapidsai:cuda9.2-runtime-ubuntu16.04

ENV CONDA_ENV rapids

RUN source activate $CONDA_ENV && \
    conda install -y unzip python-graphviz && \
    apt-get update && \
    apt-get install -y --fix-missing font-manager && \
    pip install ipyvolume dask-kubernetes matplotlib && \
    rm -rf /var/lib/apt/lists/*

COPY prepare.sh /usr/bin/prepare.sh
COPY utils /rapids/notebooks/utils
COPY k8s_examples /rapids/notebooks/k8s_examples

CMD ["jupyter", "lab", "--ip=0.0.0.0", "--allow-root", "--no-browser", "--NotebookApp.token='dask'"]
ENTRYPOINT ["tini", "--", "/usr/bin/prepare.sh"]
