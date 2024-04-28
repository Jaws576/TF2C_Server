DIR=/app/server
DAEMON=$DIR/srcds_run
PARAMS="-game tf2classic -maxplayers 24 +map koth_viaduct"
NAME=SRCDS


case $1 in
      start)
	  	  screen -S $NAME -X quit
          screen -d -m -S $NAME $DAEMON $PARAMS
		  echo "starting server"
          ;;
      stop)
          screen -S $NAME -X quit
		  echo "stopping server"
          ;;
      restart)
          screen -S $NAME -X quit
          screen -d -m -S $NAME $DAEMON $PARAMS
          ;;
      update)
          screen -S $NAME -X quit
		  git -C /home/ubuntu/TF2C_Server pull
          /app/updater/TF2CDownloaderLinux --update /app/server/
		  /bin/cp -rf /home/ubuntu/TF2C_Server/dist/linux/* /app/server
		  cat /home/ubuntu/localserver.cfg >> /app/server/tf2classic/cfg/server.cfg
		  /app/steamcmd/steamcmd.sh +force_install_dir /app/server/ +login anonymous +app_update 244310 validate +quit
          screen -d -m -S $NAME $DAEMON $PARAMS
          ;;
esac

exit 0
