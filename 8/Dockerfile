FROM govpf/debian:trixie

LABEL org.opencontainers.image.title="Redis"
LABEL org.opencontainers.image.description="Redis 8 on Debian Trixie"

ENV REDIS_VERSION=8.2.1
ENV REDIS_DOWNLOAD_URL=https://download.redis.io/releases/redis-${REDIS_VERSION}.tar.gz

ENV GOSU_VERSION=1.17

# redis user
RUN groupadd --system --gid 999 redis \
 && useradd --system --uid 999 --gid redis --home-dir /data redis

# Build dependencies
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        wget \
        gcc \
        make \
        libc6-dev \
        libssl-dev \
        pkg-config \
        tcl \
    ; \
    rm -rf /var/lib/apt/lists/*

# gosu
RUN set -eux; \
    dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
    wget -O /usr/local/bin/gosu \
      "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-${dpkgArch}"; \
    chmod +x /usr/local/bin/gosu; \
    gosu --version

# Build Redis
RUN set -eux; \
    wget -O redis.tar.gz "${REDIS_DOWNLOAD_URL}"; \
    mkdir -p /usr/src/redis; \
    tar -xzf redis.tar.gz -C /usr/src/redis --strip-components=1; \
    rm redis.tar.gz; \
    make -C /usr/src/redis/deps -j"$(nproc)"; \
    make -C /usr/src/redis -j"$(nproc)" BUILD_TLS=yes MALLOC=libc; \
    make -C /usr/src/redis install; \
    rm -rf /usr/src/redis

# Data directory
RUN mkdir -p /data \
 && chown redis:redis /data

VOLUME /data
WORKDIR /data

COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 6379

CMD ["redis-server"]