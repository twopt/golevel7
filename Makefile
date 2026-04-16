SHELL := /usr/bin/env bash -euo pipefail -c  

.DEFAULT_GOAL := all
.PHONY: all
all: ## build pipeline
all: mod-tidy generate test lint cover build

.PHONY: ci
ci: ## CI pipeline (all except build)
ci: mod-tidy generate test cover lint

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: clean
clean: mod-tidy ## remove files created during build pipeline
	$(call print-target)
	rm -rf dist
	rm -f coverage.*
	rm -f '"$(shell go env GOCACHE)/../golangci-lint"'
	go clean -i -cache -testcache -modcache -fuzzcache -x

.PHONY: download  
download: ## Download the dependencies
	$(call print-target)
	go mod download

.PHONY: mod-tidy
mod-tidy: ## Add missing and remove unused modules from go.mod files
	$(call print-target)
	go mod tidy

.PHONY: generate
generate: ## (Re)generate all generated files
	$(call print-target)
	go generate ./...

.PHONY: build
build: ## Build a static executable using goreleaser
build:
	$(call print-target)
	go tool goreleaser build --clean --single-target --snapshot

.PHONY: lint
lint: ## Lint all code with golangci-lint
	$(call print-target)
	go tool golangci-lint run ./...

.PHONY: test  
test: ## Run all Go tests
	$(call print-target)
	go test -race ./...

.PHONY: cover  
cover: ## Create a test coverage profile
	$(call print-target)  
	go test -race -cover -covermode=atomic -coverprofile=coverage.out ./...
	go tool cover -func coverage.out


define print-target
	@printf "Executing target: \033[36m$@\033[0m\n"
endef