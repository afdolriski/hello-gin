############################
# STEP 1 build executable binary
############################
FROM golang:alpine AS builder

ARG APP_ENV=development
ENV APP_ENV ${APP_ENV}
ENV PROJECT_DIR /go/src/hello-gin

# Install git.
RUN apk update && apk add --no-cache git

RUN set -ex \
        && apk add --no-cache --virtual build-dependencies \
            build-base \
        && go get -u github.com/kardianos/govendor \
        && apk del build-dependencies

# Set the Current Working Directory inside the container
WORKDIR ${PROJECT_DIR}

COPY . .

RUN govendor sync

RUN GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -ldflags="-w -s" -o main .

############################
# STEP 2 build a small image
############################
FROM alpine:3.8

# Set Timezone
ENV TIMEZONE Asia/Jakarta
RUN apk update && apk add --no-cache tzdata ca-certificates \
  && cp /usr/share/zoneinfo/`echo $TIMEZONE` /etc/localtime && \
  apk del tzdata

# Copy our static executable.
COPY --from=builder /go/src/hello-gin/main ./main

# Expose port 8080 to the outside world
EXPOSE 3000

# Command to run the executable
CMD ["./main"]