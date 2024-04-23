# escape=`
FROM lacledeslan/steamcmd:linux as tf2classic-builder

# Install dependencies for TF2CDownloaderLinux
RUN apt update &&`
        apt install libxcb-xinerama0 -y

# Download TF2 Classic server files from content server
#RUN echo "Downloading Server Files From Content Server" &&`
#        mkdir --parents /tmp/ &&`
#        curl -sSL "https://wiki.tf2classic.com/kachemak/tf2classic.zip" -o /tmp/tf2classic.zip &&`
#    echo "Extracting" &&`
#        7z x -o/output/ /tmp/tf2classic.zip &&`
#        ls /output &&`
#        rm -f /tmp/tf2classic.zip;

RUN echo "Run community self-updater" &&`
    mkdir --parents /updater &&`
    wget "https://github.com/tf2classic/TF2CDownloader/releases/latest/download/TF2CDownloaderLinux" -P /updater &&`
    chmod +x /updater/TF2CDownloaderLinux &&`
    /updater/TF2CDownloaderLinux --install /output/;

# Download Source SDK Base 2013 Dedicated Server
RUN /app/steamcmd.sh +login anonymous +force_install_dir /output/srcds2013 +app_update 244310 validate +quit;

#=======================================================================
FROM debian:bullseye-slim

ARG BUILDNODE=unspecified
ARG SOURCE_COMMIT=unspecified

HEALTHCHECK NONE

RUN dpkg --add-architecture i386 &&`
    apt-get update && apt-get install -y `
        ca-certificates lib32gcc-s1 libtinfo5:i386 libcurl4-gnutls-dev:i386 libstdc++6 libstdc++6:i386 libtcmalloc-minimal4:i386 locales locales-all tmux zlib1g:i386 &&`
    apt-get clean &&`
    echo "LC_ALL=en_US.UTF-8" >> /etc/environment &&`
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*;

ENV LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8 LC_ALL=en_US.UTF-8

LABEL com.lacledeslan.build-node=$BUILDNODE `
      org.label-schema.schema-version="1.0" `
      org.label-schema.url="https://github.com/Jaws576/TF2C_Server/README.1ST" `
      org.label-schema.vcs-ref=$SOURCE_COMMIT `
      org.label-schema.vendor="Jaws" `
      org.label-schema.description="TF2 Classic Dedicated Server" `
      org.label-schema.vcs-url="https://github.com/Jaws576/TF2C_Server"

# Set up Enviornment
RUN useradd --home /app --gid root --system TF2Classic &&`
    mkdir -p /app/tf2classic/logs &&`
    mkdir -p /app/ll-tests &&`
    chown TF2Classic:root -R /app;

# `RUN true` lines are work around for https://github.com/moby/moby/issues/36573
COPY --chown=TF2Classic:root --from=tf2classic-builder /output/srcds2013 /app
RUN true

COPY --chown=TF2Classic:root --from=tf2classic-builder /output/tf2classic /app/tf2classic
RUN echo "forcibly link server_srv.so" &&`
    rm -rf /app/tf2classic//bin/server_srv.so &&`
    ln -s /app/tf2classic/bin/server.so /app/tf2classic/bin/server_srv.so &&`
    echo "Delete 'libstdc++.so.6' provided by Source SDK 2013 so that the newer system-provided lib is used" &&`
    rm -rf /app/bin/libstdc++.so.6;

COPY --chown=TF2Classic:root ./dist/linux/ll-tests /app/ll-tests
Run true
COPY --chown=TF2Classic:root ./dist/linux /app/

# Fix bad so names
RUN chmod +x /app/ll-tests/*.sh &&`
    ln -s /app/bin/engine_srv.so /app/bin/engine.so &&`
    ln -s /app/bin/datacache_srv.so /app/bin/datacache.so &&`
    ln -s /app/bin/dedicated_srv.so /app/bin/dedicated/so &&`
    ln -s /app/bin/vphysics_srv.so /app/bin/vphysics.so &&`
    ln -s /app/bin/studiorender_srv.so /app/bin/studiorender.so &&`
    ln -s /app/bin/soundemittersystem_srv.so /app/bin/soundemittersystem.so &&`
    ln -s /app/bin/shaderapiempty_srv.so /app/bin/shaderapiempty.so &&`
    ln -s /app/bin/scenefilecache_srv.so /app/bin/scenefilecache.so &&`
    ln -s /app/bin/replay_srv.so /app/bin/replay.so &&`
    ln -s /app/bin/materialsystem_srv.so /app/bin/materialsystem.so;

USER TF2Classic

RUN echo $'\n\nLinking steamclient.so to prevent srcds_run errors' &&`
        mkdir --parents /app/.steam/sdk32 &&`
        ln -s /app/bin/steamclient.so /app/.steam/sdk32/steamclient.so;

WORKDIR /app

CMD ["/bin/bash"]

ONBUILD USER root

