# Multi-stage Dockerfile for building and running jsluice
# Builder: compile a static Linux binary
FROM golang:1.20-alpine AS builder

# Install C toolchain and tools needed to build cgo dependencies (tree-sitter)
RUN apk add --no-cache \
	git \
	build-base \
	cmake \
	pkgconf \
	bash \
	&& rm -rf /var/cache/apk/*
WORKDIR /src

# Copy go.mod and go.sum first to leverage Docker layer caching
COPY go.mod go.sum ./
RUN go env -w GOPROXY=https://proxy.golang.org || true
RUN go mod download

# Copy full repo and build the binary
COPY . .
WORKDIR /src/cmd/jsluice
# Enable cgo so the go-tree-sitter native bindings can be built.
# Use a static-ish build where possible but allow cgo during compile.
RUN CGO_ENABLED=1 GOOS=linux GOARCH=amd64 go build -ldflags "-s -w" -o /out/jsluice

# Runtime image: small Alpine with ca-certificates
FROM alpine:3.18
RUN apk add --no-cache ca-certificates
WORKDIR /app

# Copy binary and entrypoint
COPY --from=builder /out/jsluice /usr/local/bin/jsluice
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/jsluice /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["--help"]
