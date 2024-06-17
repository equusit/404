FROM golang:1.23-alpine as builder

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
RUN go build -v -o ../../server


FROM scratch

#the app cant find templates etc unless we set the pwd
WORKDIR /app


# Copy the binary and files to the production image from the builder stage.
COPY --from=builder /app/server /app/server


EXPOSE 8080

# Run the web service on container startup.
CMD ["/app/server"]
