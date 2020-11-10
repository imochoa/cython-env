
DOCKERFILE=Dockerfile
IMGNAME=cython-env

.PHONY: build
build:
	docker build -f ${DOCKERFILE} -t ${IMGNAME} .

.PHONY: dev-build
dev-build:
	ls ${DOCKERFILE} | entr make build

# ${UID}
		# --user appuser:${GID} \
.PHONY: run
run:
	docker run \
		--rm \
		-it \
		--user ${UID}:${GID} \
		-p 127.0.0.1:80:8888 \
		-v $(pwd)/data:/data \
		${IMGNAME}

.PHONY: dev-run
dev-run:
	docker run \
		--rm \
		-it \
		--entrypoint /bin/sh \
		-p 127.0.0.1:80:8888 \
		-v $(pwd)/data:/data \
		${IMGNAME}

# docker run \
# 	--rm \
# 	-p 10000:8888 \
# 	-e JUPYTER_ENABLE_LAB=yes \
# 	-v "$(pwd)":/home/jovyan/work \
# 	jupyter/datascience-notebook:9b06df75e445

