#!/system/bin/sh
(
while true; do
  sleep 30
  BB=/data/adb/magisk/busybox
  for p in $(ls /proc 2>/dev/null); do
    case $(cat /proc/$p/cmdline 2>/dev/null | tr '\0' ' ') in
      *ffmpeg*hls*)
        PP=$(awk '{print $4}' /proc/$p/stat 2>/dev/null)
        if [ "$PP" = "1" ]; then kill -9 $p 2>/dev/null; fi
        ;;
    esac
  done
  am startservice --user 0 -n com.termux/com.termux.app.RunCommandService -a com.termux.RUN_COMMAND --es com.termux.RUN_COMMAND_PATH /data/data/com.termux/files/usr/bin/bash --esa com.termux.RUN_COMMAND_ARGUMENTS -c,/data/data/com.termux/files/home/run-relay.sh --es com.termux.RUN_COMMAND_WORKDIR /data/data/com.termux/files/home --ez com.termux.RUN_COMMAND_BACKGROUND true
done
) &
