FROM nvcr.io/nvidia/rapidsai/rapidsai:0.9-cuda10.0-runtime-ubuntu18.04

ENV CONDA_ENV rapids

RUN source activate $CONDA_ENV && \
    apt-get update && \
    apt-get install -y screen unzip git vim htop && \
    rm -rf /var/lib/apt/*

RUN source activate rapids && \
    conda install -y -c conda-forge -c rapidsai \
          nodejs \
          python-graphviz \
          ipywidgets \
          ipyvolume \
          cupy

RUN source activate $CONDA_ENV && \
    pip install --upgrade pip && \
    pip install matplotlib \
        git+https://github.com/dask/dask-kubernetes.git

RUN source activate $CONDA_ENV && \
    jupyter labextension install @jupyter-widgets/jupyterlab-manager && \
    jupyter labextension install ipyvolume && \
    jupyter labextension install jupyter-threejs && \
    jupyter labextension install dask-labextension

# There is currently a bug in the jupyterlab-manager that requires install directly from Git
# When this bug is patched we should remove this piece.
# I have left the above `jupyter labextension install @jupyter-widgets/jupyterlab-manager && \` for simplicity, but it is an extra step
RUN source activate $CONDA_ENV && \
    cd /tmp && \
    git clone https://github.com/rapidsai/jupyterlab-nvdashboard.git && \
    cd jupyterlab-nvdashboard && \
    pip install -e . && \
    jlpm install && \
    jlpm run build && \
    jupyter labextension install . 

# This contains various k8s/dask/rapids examples
COPY k8s_examples /rapids/notebooks/k8s_examples

# This installs libraries required by Dask workers running the HPO examples
RUN pip install -e "git+https://github.com/supertetelman/rapids.git@k8s#egg=rapids&subdirectory=HPO"

# This repository contains real-world scale out demos for hpyer parameter search and Dask
RUN cd /rapids/notebooks/k8s_examples && git clone --depth=1 https://github.com/miroenev/rapids.git /rapids/notebooks/k8s_examples/miro-rapids

# These are customer files used by the standard Jupyter containers and not included in the RAPIDS/conda containers
COPY prepare.sh /usr/bin/prepare.sh
COPY utils /rapids/notebooks/utils

# These commands add custom NVIDIA themeing to Jupyter Notebooks
RUN mkdir -p /root/.jupyter/custom
COPY static/* /root/.jupyter/custom/

# This run command uses the rapids conda environment, this avoids the need for `source activate rapids`
CMD ["/opt/conda/envs/rapids/bin/jupyter", "lab", "--ip=0.0.0.0", "--allow-root", "--no-browser", "--NotebookApp.token=''", "--NotebookApp.password=''", "--NotebookApp.allow_origin='*'", "--NotebookApp.base_url=''"]
ENTRYPOINT ["tini", "--", "/usr/bin/prepare.sh"]
