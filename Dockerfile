FROM golang:1.11 as builder

RUN curl -fsSL -o /usr/local/bin/dep https://github.com/golang/dep/releases/download/v0.5.0/dep-linux-amd64 \
  && chmod +x /usr/local/bin/dep

RUN mkdir -p /go/src/go-check-infra
WORKDIR /go/src/go-check-infra

COPY ./Gopkg.toml ./Gopkg.lock /go/src/go-check-infra/
RUN dep ensure -vendor-only

COPY . /go/src/go-check-infra/

RUN GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o bin/go-check-infra \
  && cp bin/go-check-infra /usr/local/bin/go-check-infra \
  && chmod +x /usr/local/bin/go-check-infra

FROM alpine:3.8 as runner

ENV TZ Asia/Tokyo
RUN apk add --update --no-cache ca-certificates tzdata py-pip bash jq && \
    cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
    pip install --no-cache-dir awscli

COPY --from=builder /usr/local/bin/go-check-infra /usr/local/bin/go-check-infra
COPY ./docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN adduser -u 1000 -s /sbin/nologin -D www-data && \
    chown www-data /usr/local/bin/go-check-infra && \
    chmod +x /usr/local/bin/go-check-infra && \
    chmod +x /usr/local/bin/docker-entrypoint.sh
USER www-data

EXPOSE 1323

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["/usr/local/bin/go-check-infra"]
