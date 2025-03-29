DOCKERFILE_LOCATION=./deploy/Dockerfile
DOCKERCOMPOSE_LOCATION=deploy/docker-compose-local.yaml
SERVICE_NAME=coi-ai-tasks-service
IMAGE_TAG ?= latest

# AWS Envs
AWS_ECR_NAME=723078827062.dkr.ecr.us-east-1.amazonaws.com
AWS_ECR_URL=$(AWS_ECR_NAME)/$(SERVICE_NAME)
REGION=us-east-1
PROFILE=coi-e2x


login:
	@aws ecr get-login-password --profile $(PROFILE) --region $(REGION) | docker login --username AWS --password-stdin $(AWS_ECR_NAME)

create_repo:
	@aws ecr create-repository --repository-name $(SERVICE_NAME) --profile $(PROFILE) --region $(REGION) > /dev/null

build:
	@docker build -f $(DOCKERFILE_LOCATION) --no-cache -t $(SERVICE_NAME) .

tag:
	@docker tag $(SERVICE_NAME):latest $(AWS_ECR_URL):$(IMAGE_TAG)

push:
	@docker push $(AWS_ECR_URL):$(IMAGE_TAG)

run:
	@docker run $(SERVICE_NAME):$(IMAGE_TAG)

update_docker_image: build tag push


# Commands for the local development

start_local_services:
	@echo ">> Launch Localstack and MySQL database in containers"
	@docker compose -f $(DOCKERCOMPOSE_LOCATION) up -d
	@sleep 20

db_restore:
	@cat $(DB_DUMP_PATH) | docker exec -i $(DB_CONTAINER_NAME) /usr/bin/mysql -u $(DB_USER) --password=$(DB_PASWORD) $(DB_NAME)


cluster_start: start_local_services db_restore

cluster_stop:
	@echo ">>> Stopping cluster"
	@docker compose -f $(DOCKERCOMPOSE_LOCATION) down --remove-orphans

cluster_restart: cluster_stop cluster_start

