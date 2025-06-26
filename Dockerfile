FROM swift:6.1-jammy

RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get install -y \
    libsasl2-dev \
    libssl-dev \
    libjemalloc-dev \
    && apt-get -q dist-upgrade -y \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Package.swift Package.resolved ./
COPY Sources ./Sources

RUN swift build -c release

CMD ["/app/.build/release/Producer"]
