DIR=/app/server
DAEMON=$DIR/srcds_run
PARAMS="-game tf2classic -maxplayers 24 +map pl_badwater"
NAME=SRCDS


case $1 in
      start)
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
          /app/updater/TF2CDownloaderLinux --update /app/server/
		  steamcmd +force_install_dir /app/server/ +login anonymous +app_update 244310 validate +quit
          screen -d -m -S $NAME $DAEMON $PARAMS
          ;;
esac

exit 0