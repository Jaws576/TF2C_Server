
# Install dependencies for TF2CDownloaderLinux
apt-get update;
apt-get install libxcb-xinerama0 -y;
apt-get install screen -y;

add-apt-repository multiverse
dpkg --add-architecture i386;
apt-get update;
apt-get install -y ca-certificates steamcmd lib32z1 libncurses5:i386 libbz2-1.0:i386 lib32gcc-s1 lib32stdc++6 libtinfo5:i386 libcurl3-gnutls:i386 libsdl2-2.0-0:i386 libcurl4-gnutls-dev libcurl4-gnutls-dev:i386
apt-get clean;
echo "LC_ALL=en_US.UTF-8" >> /etc/environment;
rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*;

wget "https://github.com/tf2classic/TF2CDownloader/releases/latest/download/TF2CDownloaderLinux" -P /app/updater;
wget -qO- http://media.steampowered.com/installer/steamcmd_linux.tar.gz | tar xz -C /app/steamcmd;

# Download Source SDK Base 2013 Dedicated Server
su -c "steamcmd +quit" ubuntu;
su -c "steamcmd +force_install_dir /app/server/ +login anonymous +app_update 244310 validate +quit" ubuntu;

mkdir -p /app/server/tf2classic/logs;
mkdir -p /app/server/ll-tests;

chmod +x /app/updater/TF2CDownloaderLinux
/app/updater/TF2CDownloaderLinux --install /app/server/;
rm -rf /var/tmp/*;
apt-get purge steamcmd

cp -r ./dist/linux/* /app/server/

rm -rf /app/server/tf2classic/bin/server_srv.so;
ln -s /app/server/tf2classic/bin/server.so /app/server/tf2classic/bin/server_srv.so;


ln -s /app/server/bin/engine_srv.so /app/server/bin/engine.so;
ln -s /app/server/bin/datacache_srv.so /app/server/bin/datacache.so;
ln -s /app/server/bin/dedicated_srv.so /app/server/bin/dedicated.so;
ln -s /app/server/bin/vphysics_srv.so /app/server/bin/vphysics.so;
ln -s /app/server/bin/studiorender_srv.so /app/server/bin/studiorender.so;
ln -s /app/server/bin/soundemittersystem_srv.so /app/server/bin/soundemittersystem.so;
ln -s /app/server/bin/shaderapiempty_srv.so /app/server/bin/shaderapiempty.so;
ln -s /app/server/bin/scenefilecache_srv.so /app/server/bin/scenefilecache.so;
ln -s /app/server/bin/replay_srv.so /app/server/bin/replay.so;
ln -s /app/server/bin/materialsystem_srv.so /app/server/bin/materialsystem.so;

mkdir --parents /home/ubuntu/.steam/sdk32;
ln -s /app/server/bin/steamclient.so /home/ubuntu/.steam/sdk32/steamclient.so;
chown -R ubuntu /app/
