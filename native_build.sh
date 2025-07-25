#!/bin/bash

cd "$(dirname "$0")"
NEEDRESTART_MODE=a
# Install dependencies for TF2CDownloaderLinux
apt-get update;
apt-get install libxcb-xinerama0 software-properties-common screen cron -y;

add-apt-repository multiverse -y
dpkg --add-architecture i386;
apt-get update;
apt-get install -y ca-certificates lib32z1 libbz2-1.0:i386 lib32gcc-s1 lib32stdc++6 libcurl3-gnutls:i386 libsdl2-2.0-0:i386 libcurl4-gnutls-dev:i386
apt-get install `apt-cache depends pkgname | awk '/Depends:/{print$2}'`
apt-get clean;
echo "LC_ALL=en_US.UTF-8" >> /etc/environment;
rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*;

mkdir -p /app/steamcmd

wget "https://github.com/tf2classic/TF2CDownloader/releases/latest/download/TF2CDownloaderLinux" -P /app/updater;
wget -qO- http://media.steampowered.com/installer/steamcmd_linux.tar.gz | tar xz -C /app/steamcmd;

chown -R ubuntu /app/
chmod +x /app/steamcmd/steamcmd.sh

# Download Source SDK Base 2013 Dedicated Server
su ubuntu -c "/app/steamcmd/steamcmd.sh +force_install_dir /app/server/ +login anonymous +app_update 244310 -beta previous2021 validate +quit"

mkdir -p /app/server/ll-tests;

chmod +x /app/updater/TF2CDownloaderLinux
/app/updater/TF2CDownloaderLinux --install /app/server/;

chown ubuntu /var/tmp/*

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

if [$1 = ""];
then
        max="1"
else
        max=$1
fi
for i in $(seq $max)
do
        name="server"$i
        echo $name
        mkdir --parents /home/ubuntu/overrides/$name/tf2classic/addons
        mkdir --parents /home/ubuntu/overrides/$name/tf2classic/cfg
        mkdir --parents /app/$name/tf2classic
        cp /app/server/srcds_run /app/$name/
        cp -r /app/server/tf2classic/cfg /app/$name/tf2classic/
        cp -r /app/server/tf2classic/addons /app/$name/tf2classic/
        ln -s /app/server/tf2classic/* /app/$name/tf2classic/
        ln -s /app/server/* /app/$name/
done

ln -s /app/server/bin/steamclient.so /home/ubuntu/.steam/sdk32/steamclient.so;

cp ./rc.local /etc/
chown -R ubuntu /app/
chown -R ubuntu /home/ubuntu/

echo "alias server='bash ~/TF2C_Server/server.sh'" >> ~/.bash_aliases
