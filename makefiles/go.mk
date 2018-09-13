.PHONY: build lint run vet test check

build: $(wildcard $(shell find . -type f | grep "\.go"))
	CGO_ENABLED=0 go build -o ./bin/$(name) -a -installsuffix cgo -ldflags '-s' .

# https://github.com/golang/lint
# go get github.com/golang/lint/golint
lint: $(wildcard $(shell find . -type f | grep "\.go"))
	golint `go list ./... | grep -v /vendor/`

run: build
	./bin/$(name)

# http://godoc.org/code.google.com/p/go.tools/cmd/vet
# go get code.google.com/p/go.tools/cmd/vet
vet: $(wildcard $(shell find . -type f | grep "\.go"))
	go vet `go list ./... | grep -v /vendor/`

check: test vet lint

test:
	go test -cover `go list ./... | grep -v /vendor/`

cyclo:
	ls | grep -v vendor | xargs -n 1 gocyclo -over 10 2> /dev/null | sort
