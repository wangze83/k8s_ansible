PROJECT_NAME := wzmnt
HARBOR := x.wz.net/public
VERSION := 0.01

release:
	docker build -f ./Dockerfile \
		-t $(HARBOR)/$(PROJECT_NAME):$(VERSION) .

push:
	docker push $(HARBOR)/$(PROJECT_NAME):$(VERSION)
