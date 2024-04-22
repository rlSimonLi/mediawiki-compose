# Put the MediaWiki installation path on the line below
MW_INSTALL_PATH="/var/www/html"
RUN_PHP="$MW_INSTALL_PATH/maintenance/run.php"
RUN_JOBS="$RUN_PHP runJobs.php"
SHOW_JOBS="$RUN_PHP showJobs.php"
echo "$(date '+%Y-%m-%d %H:%M:%S') Starting job service... Waiting for 60 seconds for services to start up..."
# Wait a minute after the server starts up to give other processes time to get started
sleep 60
echo "$(date '+%Y-%m-%d %H:%M:%S') Started."
while true; do
    php $SHOW_JOBS --group
	php $RUN_JOBS --maxtime=10 --memory-limit=1G --wait
	echo "$(date '+%Y-%m-%d %H:%M:%S') Waiting for 60 seconds..."
	sleep 60
done