PID=$( ps -fu $LOGNAME |awk '/http.server/ && !/awk/ { print $2}' )
kill -INT $PID


