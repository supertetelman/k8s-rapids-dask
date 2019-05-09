FROM nvcr.io/nvidia/rapidsai/rapidsai:cuda9.2-runtime-ubuntu16.04

ENV CONDA_ENV rapids

RUN source activate $CONDA_ENV && \
    apt-get update && \
    conda install -c conda-forge nodejs unzip python-graphviz && \
    apt-get install -y --fix-missing font-manager && \
    rm -rf /var/lib/apt/lists/* && \
    pip install --upgrade pip && \
    pip install ipyvolume \       
        matplotlib \
        git+https://github.com/dask/dask-kubernetes.git \
        jupyter jupyterlab dask-labextension && \
   jupyter labextension install dask-labextension

COPY prepare.sh /usr/bin/prepare.sh
COPY utils /rapids/notebooks/utils
COPY k8s_examples /rapids/notebooks/k8s_examples
RUN mkdir -p /root/.jupyter/custom
COPY static/* /root/.jupyter/custom/

CMD ["jupyter", "lab", "--ip=0.0.0.0", "--allow-root", "--no-browser", "--NotebookApp.token='dask'"]
ENTRYPOINT ["tini", "--", "/usr/bin/prepare.sh"]
