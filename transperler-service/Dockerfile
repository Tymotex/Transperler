############################
# STEP 1 build executable binary
############################
FROM golang:alpine AS builder

# Install git, which is required for fetching the dependencies.
RUN apk update && apk add --no-cache 'git=~2'

# Install dependencies.
ENV GO111MODULE=on
WORKDIR /app
COPY . /app

# Fetch dependencies using go get.
RUN go get -d -v

# Build the binary.
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o /go/main .

############################
# STEP 2 build a small image
############################
FROM alpine:3

# Install Perl.
RUN apk update && apk add --no-cache perl

WORKDIR /app

# Copy our static executable.
COPY --from=builder /go/main /go/main

ENV PORT 8080
ENV GIN_MODE release
EXPOSE 8080

# Run the Go Gin binary.
ENTRYPOINT ["/go/main"]
