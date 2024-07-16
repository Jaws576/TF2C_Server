params="-game tf2classic -maxplayers 24 +map koth_viaduct"
name=SRCDS

if [ -z "$2" ]
then
        pattern="server?*"
else
        pattern=$2
fi

case $1 in
	start)
		for path in /app/$pattern;
		do
			params=$(< $path/serverparams.cfg)
			name=$(basename $path)
			screen -S $name -X quit
			screen -d -m -S $name $path/srcds_run $params
			echo "starting server at "$path" with params "$params
		done
		;;
	stop)
		for path in /app/$pattern;
		do
			name=$(basename $path)
          		screen -S $name -p 0 -X stuff 'exit^M'
          		echo "stopping server at "$path
          	done
		;;
	restart)
		./$0 stop $2
		sleep 3
		./$0 start $2
		;;
	update)
          	./$0 stop $2
          	sleep 3
          	git -C /home/ubuntu/TF2C_Server pull
          	/app/updater/TF2CDownloaderLinux --update /app/server/
          	rm -r /app/server/tf2classic/addons
          	rm -r /app/server/tf2classic/cfg/sourcemod
          	/bin/cp -rf /home/ubuntu/TF2C_Server/dist/linux/* /app/server
          	/bin/cp -rf /app/server
          	/app/steamcmd/steamcmd.sh +force_install_dir /app/server/ +login anonymous +app_update 244310 validate +quit
		for path in /app/$pattern;
		do
			name=$(basename $path)
			rm -r $path/addons
			rm -r $path/cfg
			cp -r /app/server/tf2classic/addons $path/tf2classic
			cp -r /app/server/tf2classic/cfg $path/tf2classic
			/bin/cp -rf /home/overrides/$name $path
			ln /app/server/tf2classic/* $path/tf2classic
			ln /app/server/* $path
		done
		./$0 start $2
		;;
      command)
          screen -S $NAME -p 0 -X stuff "$2^M"
esac

exit 0

