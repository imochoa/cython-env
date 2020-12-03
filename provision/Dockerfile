FROM continuumio/miniconda3:4.8.2

# Add Tini
ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini

RUN chmod +x /tini                                                                          \
    && apt-get update                                                                       \
    && apt-get upgrade -y                                                                   \
    && apt-get install -y                                                                   \
        libpq-dev                                                                           \
        build-essential                                                                     \
        git                                                                                 \
        sudo                                                                                \
        cmake zlib1g-dev libjpeg-dev xvfb ffmpeg xorg-dev libboost-all-dev libsdl2-dev swig \
        unzip zip nodejs npm                                                                \
    && rm -rf /var/lib/apt/lists/*

# Extra dependencies for wand
# RUN apt-get update \
#     && apt-get install -y libmagickwand-dev \
#     && apt-get install -y xvfb
ARG envname=devenv
COPY provision/dotfiles/environment.yml /tmp/
RUN conda update -y -n base conda                                     \
    && echo '    - pyvirtualdisplay' >> /tmp/environment.yml          \
    && conda env create --file /tmp/environment.yml --name ${envname} \
    && conda clean -y -t                                              \
    && rm /tmp/environment.yml

ARG username=devel
ARG userid=1000

ARG home=/home/${username}
ARG workdir=${home}/workdir

RUN adduser ${username} --uid ${userid} --gecos '' --disabled-password         \
    && echo "${username} ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/${username} \
    && chmod 0440 /etc/sudoers.d/${username}                                   \
    && chown -R ${username}:${username} ${home}/


COPY provision/dotfiles/bashrc.bash /tmp/
ENV PATH /opt/conda/envs/${envname}/bin:$PATH
RUN git-nbdiffdriver config --enable --global \
    && git config --global diff.jupyternotebook.command 'git-nbdiffdriver diff --ignore-details'



RUN cat /tmp/bashrc.bash >> ${home}/.bashrc                                  \
    && echo "export PATH=\"${workdir}/docker/bin:$PATH\"" >> ${home}/.bashrc \
    && sudo rm /tmp/bashrc.bash

# RUN chown -R ${username}:${username} /opt/conda/envs/

# RUN chown -R ${username}:${username} /opt/conda/envs/${envname}/bin
# RUN ln -s /opt/conda/envs/${envname}/bin/jupyter ${workdir}/jupy

#RUN ln -s /opt/conda/envs/${envname}/bin/jupyter /jupyter

RUN jupyter-lab build
USER ${username}

# RUN ln -s /opt/conda/envs/${envname}/bin/jupyter ${workdir}/jupy

# INFO: Uncomment lines below to enable automatic save of python-only and html-only
#       exports alongside the notebook
#COPY dotfiles/jupyter_notebook_config.py /tmp/
#RUN cat /tmp/jupyter_notebook_config.py >> ${home}/.jupyter/jupyter_notebook_config.py
#RUN sudo rm /tmp/jupyter_notebook_config.py

# INFO: Uncomment the RUN command below to disable git diff paging
#RUN git config --global core.pager ''


# INFO: Uncomment the RUN command below for easy and constant notebook URL (just localhost:8888)
#       That will switch Jupyter to using empty password instead of a token.
#       To avoid making a security hole you SHOULD in fact not only uncomment but
#       regenerate the hash for your own non-empty password and replace the hash below.
#       You can compute a password hash in any notebook, just run the code:
#          from notebook.auth import passwd
#          passwd()
#       and take the hash from the output
#RUN mkdir -p ${home}/.jupyter && \
#    echo 'c.NotebookApp.password = u"sha1:c6bbcba2d04b:f969e403db876dcfbe26f47affe41909bd53392e"' \
#    >> ${home}/.jupyter/jupyter_notebook_config.py


    # ports:
    #   - "8888:8888"
    #   - "6006:6006"

VOLUME /home/${username}/workdir
WORKDIR /home/${username}/workdir
# RUN ls /opt/conda/envs/${envname}/bin/

ENTRYPOINT ["/tini", "--"]
# CMD ["/opt/conda/envs/tf2/bin/jupyter", "notebook", "--ip=0.0.0.0", "--port=8888", "--no-browser"]
# CMD ["/jupyter", "notebook", "--ip=0.0.0.0", "--port=8888", "--no-browser"]

CMD ["jupyter-lab", "--ip=0.0.0.0", "--port=8888", "--no-browser"]

#     command: /opt/conda/envs/tf2/bin/jupyter notebook --ip='0.0.0.0' --port=8888 --no-browser
# Run your program under Tini
# or docker run your-image /your/program ...
