# automatic makefile help
.PHONY: help deps test build format vet build-docker serve info
default: help

# # default to help target
help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  deps          install dependencies"
	@echo "  test          run tests"
	@echo "  build         build binary"
	@echo "  format        format code"
	@echo "  vet           vet code"
	@echo "  build-docker  build docker image"
	@echo "  serve         run binary"
	@echo "  info          show binary info"

ci: deps test build

deps:
	go get -u
	go get github.com/stretchr/testify

test:
	GIN_MODE=debug go test

build:
	GIN_MODE=production CGO_ENABLED=0 go build -a -o hello_world

format:
	gofmt -s -w .

vet:
	go vet ./...

build-docker:
	docker build -t hello_world .

serve:
	./hello_world

info:
	file hello_world
	sha1sum hello_world