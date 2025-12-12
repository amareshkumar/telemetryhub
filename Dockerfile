# Multi-stage build (smaller image, build cache)
FROM ubuntu:22.04 AS builder
RUN apt-get update && apt-get install -y build-essential cmake ninja-build git
WORKDIR /src
COPY . .
RUN cmake --preset linux-ninja-release && \
    cmake --build --preset linux-ninja-release --target gateway_app

FROM ubuntu:22.04 AS runtime
RUN apt-get update && apt-get install -y libstdc++6 && rm -rf /var/lib/apt/lists/*
COPY --from=builder /src/build/gateway/gateway_app /usr/local/bin/
COPY docs/config.example.ini /etc/telemetryhub/config.ini
EXPOSE 8080
HEALTHCHECK --interval=30s CMD curl -f http://localhost:8080/status || exit 1
CMD ["gateway_app", "--config", "/etc/telemetryhub/config.ini"]
