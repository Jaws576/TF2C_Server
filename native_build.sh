
# Install dependencies for TF2CDownloaderLinux
apt-get update;
apt-get install libxcb-xinerama0 -y;


dpkg --add-architecture i386;
apt-get update;
apt-get install -y ca-certificates lib32gcc-s1 libtinfo5:i386 libcurl4-gnutls-dev:i386 libstdc++6 libstdc++6:i386 libtcmalloc-minimal4:i386 locales locales-all tmux zlib1g:i386;
apt-get clean;
echo "LC_ALL=en_US.UTF-8" >> /etc/environment;
rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*;

mkdir -p /app/steamcmd/
wget "https://github.com/tf2classic/TF2CDownloader/releases/latest/download/TF2CDownloaderLinux" -P /app/updater;
wget -qO- http://media.steampowered.com/installer/steamcmd_linux.tar.gz | tar xz -C /app/steamcmd;
chmod +x /app/steamcmd/steamcmd.sh;

# Download Source SDK Base 2013 Dedicated Server
/app/steamcmd/steamcmd.sh +force_install_dir +login anonymous /app/server/ +app_update 244310 validate +quit;

mkdir -p /app/server/tf2classic/logs;
mkdir -p /app/server/ll-tests;

chmod +x /app/updater/TF2CDownloaderLinux
/app/updater/TF2CDownloaderLinux --install /app/server/;
rm -rf /var/tmp/*;
rm -rf /app/steamcmd

cp -r ./dist/linux/* /app/server/

rm -rf /app/server/tf2classic/bin/server_srv.so;
ln -s /app/server/tf2classic/bin/server.so /app/tf2classic/bin/server_srv.so;
rm -rf /app/server/bin/libstdc++.so.6;


ln -s /app/server/bin/engine_srv.so /app/bin/engine.so;
ln -s /app/server/bin/datacache_srv.so /app/bin/datacache.so;
ln -s /app/server/bin/dedicated_srv.so /app/bin/dedicated.so;
ln -s /app/server/bin/vphysics_srv.so /app/bin/vphysics.so;
ln -s /app/server/bin/studiorender_srv.so /app/bin/studiorender.so;
ln -s /app/server/bin/soundemittersystem_srv.so /app/bin/soundemittersystem.so;
ln -s /app/server/bin/shaderapiempty_srv.so /app/bin/shaderapiempty.so;
ln -s /app/server/bin/scenefilecache_srv.so /app/bin/scenefilecache.so;
ln -s /app/server/bin/replay_srv.so /app/bin/replay.so;
ln -s /app/server/bin/materialsystem_srv.so /app/bin/materialsystem.so;

mkdir --parents /app/server/.steam/sdk32;
ln -s /app/server/bin/steamclient.so /app/server/.steam/sdk32/steamclient.so;
