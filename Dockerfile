# build
FROM alpine:3.10 as crystalbuilder
RUN echo '@edge http://dl-cdn.alpinelinux.org/alpine/edge/community' >> /etc/apk/repositories
RUN echo '@edge http://dl-cdn.alpinelinux.org/alpine/edge/main' >> /etc/apk/repositories
RUN apk add --update --no-cache --force-overwrite \
        crystal@edge \
        shards@edge \
        g++ \
        gc-dev \
        libunwind-dev \
        libxml2-dev \
        llvm8 \
        llvm8-dev \
        llvm8-libs \
        llvm8-static \
        make \
        musl-dev \
        openssl-dev \
        pcre-dev \
        readline-dev \
        yaml-dev \
        zlib-dev

WORKDIR /src
COPY *.c /src/
COPY *.cr /src/
COPY shard.* /src/
COPY Makefile /src/

RUN shards
RUN make

# prod
FROM alpine:3

WORKDIR /app
COPY .env.dist /app/.env
COPY --from=crystalbuilder /src/pidman /app/pidman

CMD ["./pidman"]
