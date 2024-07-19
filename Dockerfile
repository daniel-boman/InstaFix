# build binary file
FROM golang:1.22-alpine AS builder

RUN apk --update upgrade && apk add --no-cache git make build-base && rm -rf /var/cache/apk/*

RUN mkdir /app 
WORKDIR /app
COPY go.mod .
COPY go.sum .

RUN go mod download 

COPY . .

ARG buildOptions

RUN env ${buildOptions} go build -ldflags="-w -s" -o /go/bin/instafix .

# optimized build

FROM alpine 
RUN apk add --no-cache tzdata
RUN apk add --no-cache curl 
ENV TZ=Europe/Stockholm
COPY --from=builder /go/bin/instafix /go/bin/instafix

RUN apk --update upgrade && apk add --no-cache ca-certificates && update-ca-certificates 2>/dev/null && true && rm -rf /var/cache/apk/*

EXPOSE 3000

ENTRYPOINT ["/go/bin/instafix"]