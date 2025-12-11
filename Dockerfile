FROM ubuntu:22.04
RUN apt-get update && apt-get install -y build-essential cmake ninja-build
COPY . /app
WORKDIR /app
RUN cmake --preset linux-ninja-release && cmake --build --preset linux-ninja-release
CMD ["./build/gateway/gateway_app"]