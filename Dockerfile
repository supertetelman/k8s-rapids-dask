FROM nvcr.io/nvidia/rapidsai/rapidsai:0.9-cuda10.0-runtime-ubuntu18.04

ENV CONDA_ENV rapids

RUN source activate $CONDA_ENV && \
    apt-get update && \
    apt-get install -y screen unzip git vim htop && \
    rm -rf /var/lib/apt/*

RUN source activate rapids && conda install -y -c conda-forge -c rapidsai nodejs python-graphviz ipywidgets ipyvolume cupy

RUN source activate $CONDA_ENV && \
    pip install --upgrade pip && \
    pip install matplotlib \
        git+https://github.com/dask/dask-kubernetes.git

RUN source activate $CONDA_ENV && \
    jupyter labextension install @jupyter-widgets/jupyterlab-manager && \
    jupyter labextension install ipyvolume && \
    jupyter labextension install jupyter-threejs && \
    jupyter labextension install dask-labextension

COPY prepare.sh /usr/bin/prepare.sh
COPY utils /rapids/notebooks/utils
COPY k8s_examples /rapids/notebooks/k8s_examples
RUN mkdir -p /root/.jupyter/custom
COPY static/* /root/.jupyter/custom/

CMD ["jupyter", "lab", "--ip=0.0.0.0", "--allow-root", "--no-browser", "--NotebookApp.token='dask'"]
ENTRYPOINT ["tini", "--", "/usr/bin/prepare.sh"]
