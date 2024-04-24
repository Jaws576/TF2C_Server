DIR=/app/server
DAEMON=$DIR/srcds_run
PARAMS="-game tf2classic -maxplayers 24 +map pl_badwater"
NAME=SRCDS


case $1 in
      start)
          screen -d -m -S $NAME $DAEMON $PARAMS
          ;;
      stop)
          screen -S $NAME -X quit
          ;;
      restart)
          screen -S $NAME -X quit
          screen -d -m -S $NAME $DAEMON $PARAMS
          ;;
      update)
          screen -S $NAME -X quit
          /app/updater/TF2CDownloaderLinux --update /app/server/
          rm -rf /var/tmp/*;
          screen -d -m -S $NAME $DAEMON $PARAMS
          ;;
esac

exit 0
