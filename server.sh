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
	patch)
		./$0 stop $2
		git -C /home/ubuntu/TF2C_Server pull
		/bin/cp -rf /home/ubuntu/TF2C_Server/dist/linux/* /app/server
		for path in /app/server?*;
		do
			name=$(basename $path)
			cp -r /app/server/tf2classic/addons/ $path/tf2classic
			cp -r /app/server/tf2classic/cfg/ $path/tf2classic
			/bin/cp -rf /home/ubuntu/overrides/$name/* $path
			cat $path/tf2classic/cfg/serveroverride.cfg >> $path/tf2classic/cfg/server.cfg
		done
		;;
	update)
          	./$0 stop $2
          	sleep 3
          	git -C /home/ubuntu/TF2C_Server pull
          	rm -r /app/server/tf2classic
          	/app/updater/TF2CDownloaderLinux --install /app/server/
          	/bin/cp -rf /home/ubuntu/TF2C_Server/dist/linux/* /app/server
          	/app/steamcmd/steamcmd.sh +force_install_dir /app/server/ +login anonymous +app_update 244310 validate +quit
		for path in /app/server?*;
		do
			name=$(basename $path)
			rm -r $path/*
			mkdir $path/tf2classic/
			cp -r /app/server/tf2classic/addons/ $path/tf2classic
			cp -r /app/server/tf2classic/cfg/ $path/tf2classic
			/bin/cp -rf /home/ubuntu/overrides/$name/* $path
   			cat $path/tf2classic/cfg/serveroverride.cfg >> $path/tf2classic/cfg/server.cfg
			ln -s /app/server/tf2classic/* $path/tf2classic
			ln -s /app/server/* $path
		done
		;;
	updatearchive)
			./$0 stop
			link=$2
			sleep 3
			git -C /home/ubuntu/TF2C_Server pull
			rm -r /app/server/tf2classic
			wget $link -O /app/server/tf2classic.7z
			7za x /app/server/tf2classic.7z/ -o/app/server/
			rm /app/server/tf2classic/bin/server_srv.so
			ln -s /app/server/tf2classic/bin/server.so /app/server/tf2classic/bin/server_srv.so
			/bin/cp -rf /home/ubuntu/TF2C_Server/dist/linux/* /app/server
          	/app/steamcmd/steamcmd.sh +force_install_dir /app/server/ +login anonymous +app_update 244310 validate +quit
		for path in /app/server?*;
		do
			name=$(basename $path)
			rm -r $path/*
			mkdir $path/tf2classic/
			cp -r /app/server/tf2classic/addons/ $path/tf2classic
			cp -r /app/server/tf2classic/cfg/ $path/tf2classic
			/bin/cp -rf /home/ubuntu/overrides/$name/* $path
   			cat $path/tf2classic/cfg/serveroverride.cfg >> $path/tf2classic/cfg/server.cfg
			ln -s /app/server/tf2classic/* $path/tf2classic
			ln -s /app/server/* $path
		done
		;;
	command)
	  	for path in /app/server?*;
		do
  		name=$(basename $path)
    		screen -S $name -p 0 -X stuff "$2^M"
	  	done
esac

exit 0

