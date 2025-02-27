FROM docker.1ms.run/golang:1.23-alpine as builder

ENV TZ=Asia/Shanghai \
    LANG=C.UTF-8 \
    LANGUAGE=C.UTF-8

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories && \
    apk update && apk add --no-cache dumb-init git docker-cli gcc g++ wget tzdata&& \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" >/etc/timezone

WORKDIR /work

RUN go env -w GOPROXY=https://goproxy.cn,direct && go env -w CGO_ENABLED=0
COPY go.mod go.sum ./
RUN go mod download

COPY .  ./
RUN go build -o ledger cmd/ledger/main.go

FROM docker.1ms.run/alpine:3.11

ARG HELM_VERSION=v3.5.2

RUN mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2
COPY --from=builder /work/ledger /usr/local/bin/
EXPOSE 8050
CMD ["sh"]