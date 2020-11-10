FROM alpine:3.12.1

# Install python/pip
ENV PYTHONUNBUFFERED=1
RUN addgroup -S appgroup && adduser -S appuser -G appgroup \
    && apk add --update --no-cache \
                                  python3 \
                                  python3-dev \
                                  build-base \
                                  tini \
                                  libffi-dev \
    && ln -sf python3 /usr/bin/python \
    && python3 -m ensurepip \
    && pip3 install --no-cache --upgrade pip setuptools


# Create a group and user
RUN pip install cython jupyterlab
RUN jupyter-lab --allow-root
# RUN apk add --no-cache build-base
# Tell docker that all future commands should run as the appuser user
# PORT 8888 

RUN chown -R appuser:appgroup /home/appuser/.local/share/jupyter

VOLUME /data
WORKDIR /data
# USER appuser

# ENTRYPOINT [/sbin/tini, --]
ENTRYPOINT ["tini", "--"]
# CMD ["jupyter", "lab", "/data"]
# CMD ["jupyter-lab", "--app-dir", "/data", "--ip", "0.0.0.0", "--port", "8888", "--no-browser"]
# CMD ["jupyter-lab", "--app-dir=/data", "--ip=0.0.0.0", "--port=8888", "--no-browser"]
CMD ["jupyter-lab", "--ip=*", "--port=8888", "--no-browser"]
# , "/data"]

