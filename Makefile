# vim:ft=make:

# Over-writeable variables
# You can overwrite these values when calling by doing:
# make VAR="some_other_value"
IMGNAME ?= cython-env
DOCKERFILE ?= Dockerfile
COMPOSE_PROJECT_NAME ?= cythoon-env

# Auto variables
MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
REPO_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
NOTEBOOK_DIR := ${REPO_DIR}/notebook-workdir
PROVISION_DIR := ${REPO_DIR}/provision
DOCKERFILE := ${PROVISION_DIR}/Dockerfile

DATE:=$(shell date)

CURRENT_UID := $(shell id -u)
CURRENT_GID := $(shell id -g)
DOCKER_USERNAME=devel
DOCKER_JUPYTER_PORT=8888

.PHONY: build
build:
	docker build \
		-f ${DOCKERFILE} \
		-t ${IMGNAME} \
		--build-arg username=${DOCKER_USERNAME} \
		--build-arg userid=${CURRENT_UID} \
		--build-arg CACHEBUSTER="${DATE}" \
		${REPO_DIR}

.PHONY: run
run:
	docker run \
		--rm \
		-it \
		--user ${CURRENT_UID}:${CURRENT_GID} \
		-p 127.0.0.1:80:${DOCKER_JUPYTER_PORT} \
		-p 127.0.0.1:6006:6006 \
		-v ${NOTEBOOK_DIR}:/home/${DOCKER_USERNAME}/workdir \
		${IMGNAME}

.PHONY: dev-build
dev-build:
	ls ${DOCKERFILE} | entr make build

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


help:
	cat Makefile

# echo "Creating ${NB_DIR}"; \
# echo "Need sudo permissions to change the dir ownership"; \
# mkdir -p ${NB_DIR}; sudo chown -R ${USER}:${USER} ${NB_DIR}; \

#setup:
#	if [ ! -d ${NB_DIR} ]; then \
#	printf "\nSetting up the notebook. Need sudo to change the workdir ownership!\n" && mkdir ${NB_DIR} && sudo chown -R ${USER}:${USER} ${NB_DIR};\
#	else \
#	printf "\nSetup already done!!\n";\
#   	fi

#run: stop .FORCE setup
#	docker-compose up

#xrun: stop .FORCE setup
#	xhost + ; \
#	sudo docker run \
#		-ti --rm \
#		--net=host \
#		--ipc=host \
#		--env="DISPLAY" \
#		--env QT_X11_NO_MITSHM=1 \
#		--volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
#		-v /home/ignacio/notebook-workdir:/home/devel/workdir \
#		ml-notebook \
#		/opt/conda/envs/tf2/bin/jupyter notebook --ip='0.0.0.0' --port=8888 --no-browser ; \
#		xhost -
#		# --device=/dev/video0:/dev/video0

#show-url:
#	docker-compose exec ${COMPOSE_PROJECT_NAME} jupyter notebook list
#
#tail-log:
#	docker-compose logs -f ${COMPOSE_PROJECT_NAME}
#
#exec:
#	docker-compose exec ${COMPOSE_PROJECT_NAME} bash
#
#build:
#	docker-compose build
#
#rebuild: stop .FORCE
#	docker-compose build --force-rm


stop:
	docker stop ${COMPOSE_PROJECT_NAME} || true; docker rm -f ${COMPOSE_PROJECT_NAME} || true;

.FORCE:
