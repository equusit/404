FROM golang:1.20-alpine as builder

# Create and change to the app directory.
WORKDIR /app

# Retrieve application dependencies.
# This allows the container build to reuse cached dependencies.
# Expecting to copy go.mod and if present go.sum.
COPY go.* ./
RUN go mod download
COPY cmd ./cmd/
COPY pkg ./pkg/
COPY static ./static/
COPY templates ./templates/

## get ca certs
RUN apk update && apk add --no-cache git ca-certificates && update-ca-certificates

WORKDIR /app/cmd/web

# Build the binary.
RUN go build -v -o ../../server


FROM scratch

#the app cant find templates etc unless we set the pwd
WORKDIR /app
#instll certs so we can talk to the db
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# Copy the binary and files to the production image from the builder stage.
COPY --from=builder /app/server /app/server

COPY --from=builder /app/templates /app/templates/

COPY --from=builder /app/static /app/static/

EXPOSE 8080

# Run the web service on container startup.
CMD ["/app/server"]
