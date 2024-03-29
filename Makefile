APP_NAME := quickstart-go-app
PORT := 8080

BUILD_DIR := $(CURDIR)/build
BIN_DIR := $(BUILD_DIR)/bin

OS := $(shell uname -s)

.DEFAULT_GOAL := help

# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

init:
	@mkdir -p "$(BUILD_DIR)" "$(BIN_DIR)"

##@ Build

.PHONY: build
build: init ## Build and install the binary.
	go build -o build/$(APP_NAME) .

.PHONY: run
run: init build ## Locally run the server.
	@echo "➡️Launching server..."
	@go run ./main.go server

.PHONY: docker-build
docker-build: ## Build the container
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-w -s" -o build/$(APP_NAME) .
	docker build -t $(APP_NAME) .

.PHONY: docker-run
docker-run: ## Run the container
	docker run -i -t --rm -p=$(PORT):$(PORT) --name="$(APP_NAME)" $(APP_NAME)

.PHONY: shell
shell:
	docker run -i -t --rm --name="$(APP_NAME)" --entrypoint sh $(APP_NAME)

