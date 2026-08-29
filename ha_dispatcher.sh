#!/bin/bash
case "$SSH_ORIGINAL_COMMAND" in
  "/usr/local/bin/ha_metrics.sh")
    /usr/local/bin/ha_metrics.sh
    ;;
  "/usr/local/bin/thermal_throttle.sh throttle")
    /usr/local/bin/thermal_throttle.sh throttle
    ;;
  "/usr/local/bin/thermal_throttle.sh restore")
    /usr/local/bin/thermal_throttle.sh restore
    ;;
  *)
    echo "Access Denied"
    exit 1
    ;;
esac
