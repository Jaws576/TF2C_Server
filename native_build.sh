
# Install dependencies for TF2CDownloaderLinux
apt-get update;
apt-get install libxcb-xinerama0 -y;


dpkg --add-architecture i386;
apt-get update && apt-get install -y ca-certificates lib32gcc-s1 libtinfo5:i386 libcurl4-gnutls-dev:i386 libstdc++6 libstdc++6:i386 libtcmalloc-minimal4:i386 locales locales-all tmux zlib1g:i386;
apt-get install libxcb-xinerama0;
apt-get install lib32gcc1
apt-get clean;
echo "LC_ALL=en_US.UTF-8" >> /etc/environment;
rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*;

mkdir -p ~/steamcmd/
wget "https://github.com/tf2classic/TF2CDownloader/releases/latest/download/TF2CDownloaderLinux" -P ~/updater;
wget -qO- http://media.steampowered.com/installer/steamcmd_linux.tar.gz | tar xz -C ~/steamcmd;
chmod +x ~/steamcmd/steamcmd.sh;

# Download Source SDK Base 2013 Dedicated Server
~/steamcmd/steamcmd.sh +login anonymous +force_install_dir /output/srcds2013 +app_update 244310 validate +quit;

mkdir -p ~/server/tf2classic/logs;
mkdir -p ~/server/ll-tests;

cp -r ./dist/linux/* ~/server/

chmod +x ~/server/updater/TF2CDownloaderLinux
~/updater/TF2CDownloaderLinux --install ~/server/;
rm -rf /var/tmp/*;

rm -rf ~/server/tf2classic//bin/server_srv.so;
ln -s ~/server/tf2classic/bin/server.so /app/tf2classic/bin/server_srv.so;
rm -rf ~/server/bin/libstdc++.so.6;


ln -s ~/server/bin/engine_srv.so /app/bin/engine.so;
ln -s ~/server/bin/datacache_srv.so /app/bin/datacache.so;
ln -s ~/server/bin/dedicated_srv.so /app/bin/dedicated.so;
ln -s ~/server/bin/vphysics_srv.so /app/bin/vphysics.so;
ln -s ~/server/bin/studiorender_srv.so /app/bin/studiorender.so;
ln -s ~/server/bin/soundemittersystem_srv.so /app/bin/soundemittersystem.so;
ln -s ~/server/bin/shaderapiempty_srv.so /app/bin/shaderapiempty.so;
ln -s ~/server/bin/scenefilecache_srv.so /app/bin/scenefilecache.so;
ln -s ~/server/bin/replay_srv.so /app/bin/replay.so;
ln -s ~/server/bin/materialsystem_srv.so /app/bin/materialsystem.so;

mkdir --parents ~/server/.steam/sdk32;
ln -s ~/server/bin/steamclient.so /app/.steam/sdk32/steamclient.so;
