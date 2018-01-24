.PHONY build lint run vet test check

build:
	CGO_ENABLED=0 go build -o ./bin/$(name) -a -installsuffix cgo -ldflags '-s' .

# https://github.com/golang/lint
# go get github.com/golang/lint/golint
lint:
	golint `go list ./... | grep -v /vendor/`

run: build
	./bin/$(name)

# http://godoc.org/code.google.com/p/go.tools/cmd/vet
# go get code.google.com/p/go.tools/cmd/vet
vet:
	go vet `go list ./... | grep -v /vendor/`

check: test vet lint

test:
	go test -cover `go list ./... | grep -v /vendor/`
