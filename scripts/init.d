#!/bin/sh
### BEGIN INIT INFO
# Provides:          maui
# Required-Start:    $local_fs
# Should-Start:
# Required-Stop:
# Should-Stop:
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Description:       Maui job scheduler
### END INIT INFO

# TO INSTALL DO (as root):
#    cp maui /etc/init.d/maui && update-rc.d maui defaults

DESC="MAUI Job Scheduler"
NAME=maui
DAEMON=/opt/maui/sbin/$NAME
MAUI_DAEMON=$DAEMON
MAUI_HOME=/var/spool/maui
PIDFILE=$MAUI_HOME/maui.pid
SCRIPTNAME=/etc/init.d/$NAME
export MAUI_DAEMON MAUI_HOME PIDFILE


# Exit if the package is not installed
[ -x "$DAEMON" ] || exit 0

# Read configuration variable file if it is present
[ -r /etc/default/$NAME ] && . /etc/default/$NAME

# Load the VERBOSE setting and other rcS variables
[ -f /etc/default/rcS ] && . /etc/default/rcS

# Define LSB log_* functions.
. /lib/lsb/init-functions

do_start()
{
   # Return
   #   0 if daemon has been started
   #   1 if daemon was already running
   #   2 if daemon could not be started
   start-stop-daemon --start --quiet --pidfile $PIDFILE --exec $DAEMON --test > /dev/null \
      || return 1
   start-stop-daemon --start --quiet --pidfile $PIDFILE --exec $DAEMON -- \
      $DAEMON_ARGS \
      || return 2
}

do_stop()
{
   # Return
   #   0 if daemon has been stopped
   #   1 if daemon was already stopped
   #   2 if daemon could not be stopped
   #   other if a failure occurred
   start-stop-daemon --stop --quiet --retry=TERM/30/KILL/5 --pidfile $PIDFILE --name $NAME
   RETVAL="$?"
   [ "$RETVAL" = 2 ] && return 2
   start-stop-daemon --stop --quiet --oknodo --retry=0/30/KILL/5 --exec $DAEMON
   [ "$?" = 2 ] && return 2
   rm -f $PIDFILE
   return "$RETVAL"
}

do_reload() {
   start-stop-daemon --stop --signal HUP --quiet --pidfile $PIDFILE --name $NAME
   return 0
}

case "$1" in
  start)
     [ "$VERBOSE" != no ] && log_daemon_msg "Starting $DESC" "$NAME"
     do_start
     case "$?" in
        0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
        2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
     esac
     ;;
  stop)
     [ "$VERBOSE" != no ] && log_daemon_msg "Stopping $DESC" "$NAME"
     do_stop
     case "$?" in
        0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
        2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
     esac
     ;;
  reload|force-reload)
     log_daemon_msg "Reloading $DESC" "$NAME"
     do_reload
     log_end_msg $?
     ;;
  restart)
     log_daemon_msg "Restarting $DESC" "$NAME"
     do_stop
     sleep 1
     case "$?" in
       0|1)
        do_start
        case "$?" in
           0) log_end_msg 0 ;;
           1) log_end_msg 1 ;; # Old process is still running
           *) log_end_msg 1 ;; # Failed to start
        esac
        ;;
       *)
          # Failed to stop
        log_end_msg 1
        ;;
     esac
     ;;
  *)
     echo "Usage: $SCRIPTNAME {start|stop|restart|reload|force-reload}" >&2
     exit 3
   ;;
esac

:
