FROM golang:1.22-alpine as builder

# Create and change to the app directory.
WORKDIR /app

# Retrieve application dependencies.
# This allows the container build to reuse cached dependencies.
# Expecting to copy go.mod and if present go.sum.
COPY go.* ./
RUN go mod download
COPY cmd ./cmd/


WORKDIR /app/cmd

# Build the binary.
RUN go build -v -o ../server

FROM alpine:latest AS vulnscan
# Copy the built artifacts from the builder stage
COPY --from=builder /app /app
# Install Trivy
RUN apk add --no-cache curl
RUN curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin v0.48.3
# Run Trivy scan on the /app directory, fail on critical vulnerabilities
RUN echo "Starting vulnerability scan" && trivy filesystem --exit-code 1 --severity CRITICAL /app

FROM scratch

#the app cant find templates etc unless we set the pwd
WORKDIR /app


# Copy the binary and files to the production image from the builder stage.
COPY --from=vulnscan /app/server /app/server


EXPOSE 8080

# Run the web service on container startup.
CMD ["/app/server"]
