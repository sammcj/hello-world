default: help

### Example Makefile for CI/CD ###

# Let's assume CI may expect:
# make lint
# make test
# make build
# make migrate (if applicable)

lint: format vet
ci: lint deps test build migrate info
run: serve

# variable for the name of the binary
BINARY=hello_world

.PHONY: help deps test build format vet build-docker serve info migrate lint ci run

deps:
	@echo "Installing dependencies..."
	go get -u
	go get github.com/stretchr/testify

test:
	@echo "Running tests..."
	GIN_MODE=debug go test

build:
	@echo "Building binary..."
	GIN_MODE=production CGO_ENABLED=0 go build -a -o $(BINARY)

format:
	@echo "Formatting code..."
	gofmt -s -w .

vet:
	@echo "Vetting code..."
	go vet ./...

build-docker:
	@echo "Building docker image..."
	docker build -t $(BINARY) .

serve:
	@echo "Running binary..."
	./$(BINARY)

info:
	@echo "Binary info..."
	file $(BINARY)
	which sha1sum && sha1sum $(BINARY) || shasum $(BINARY)

migrate:
	@echo "(STUB): Migrating database..."

# # default to help target
help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  help          show this help"
	@echo "  lint          run linters"
	@echo "  ci            run ci"
	@echo "  run           run binary"
	@echo "  migrate       migrate database"
	@echo "  deps          install dependencies"
	@echo "  test          run tests"
	@echo "  build         build binary"
	@echo "  format        format code"
	@echo "  vet           vet code"
	@echo "  build-docker  build docker image"
	@echo "  serve         run binary"
	@echo "  info          show binary info"
