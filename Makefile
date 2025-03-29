# Variables
AWS_REGION = us-east-1
ECR_REPO_PATIENT = patient-service
ECR_REPO_APPOINTMENT = appointment-service
PATIENT_SERVICE_IMAGE = patient-service
APPOINTMENT_SERVICE_IMAGE = appointment-service
PATIENT_SERVICE_TAG = prodpatient
APPOINTMENT_SERVICE_TAG = prodappointment

# AWS CLI and Docker commands
ECR_URI_PATIENT = $(ECR_REPO_PATIENT).dkr.ecr.$(AWS_REGION).amazonaws.com
ECR_URI_APPOINTMENT = $(ECR_REPO_APPOINTMENT).dkr.ecr.$(AWS_REGION).amazonaws.com

# Authenticate to AWS ECR
aws-ecr-login:
	aws ecr get-login-password --region $(AWS_REGION) | docker login --username AWS --password-stdin $(ECR_URI_PATIENT)
	aws ecr get-login-password --region $(AWS_REGION) | docker login --username AWS --password-stdin $(ECR_URI_APPOINTMENT)

# Build Docker images
build-patient-service:
	docker build -t $(PATIENT_SERVICE_IMAGE) ./patient-service

build-appointment-service:
	docker build -t $(APPOINTMENT_SERVICE_IMAGE) ./appointment-service

# Tag Docker images for AWS ECR
tag-patient-service:
	docker tag $(PATIENT_SERVICE_IMAGE):$(PATIENT_SERVICE_TAG) $(ECR_URI_PATIENT)/$(ECR_REPO_PATIENT):$(PATIENT_SERVICE_TAG)

tag-appointment-service:
	docker tag $(APPOINTMENT_SERVICE_IMAGE):$(APPOINTMENT_SERVICE_TAG) $(ECR_URI_APPOINTMENT)/$(ECR_REPO_APPOINTMENT):$(APPOINTMENT_SERVICE_TAG)

# Push Docker images to AWS ECR
push-patient-service:
	docker push $(ECR_URI_PATIENT)/$(ECR_REPO_PATIENT):$(PATIENT_SERVICE_TAG)

push-appointment-service:
	docker push $(ECR_URI_APPOINTMENT)/$(ECR_REPO_APPOINTMENT):$(APPOINTMENT_SERVICE_TAG)

# Build, tag, and push both services to ECR
push-all:
	$(MAKE) build-patient-service
	$(MAKE) build-appointment-service
	$(MAKE) aws-ecr-login
	$(MAKE) tag-patient-service
	$(MAKE) tag-appointment-service
	$(MAKE) push-patient-service
	$(MAKE) push-appointment-service

# Optional: Clean up Docker images locally
clean:
	docker system prune -f
