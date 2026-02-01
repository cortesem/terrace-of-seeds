FROM debian:stable-slim AS setup

ARG SERVER_VERSION=1453

RUN apt-get update && \
    apt-get install -y wget unzip libicu-dev && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /terraria

RUN wget https://terraria.org/api/download/pc-dedicated-server/terraria-server-$SERVER_VERSION.zip && \
    unzip -j terraria-server-$SERVER_VERSION.zip "$SERVER_VERSION/Linux/*" -d . && \
    rm terraria-server-$SERVER_VERSION.zip && \
    chmod +x TerrariaServer.bin.x86_64

FROM debian:stable-slim

WORKDIR /terraria

COPY --from=setup /terraria .

EXPOSE 7777

CMD ["./TerrariaServer.bin.x86_64", "-world", "/world/world.wld", "-autocreate", "3"]

