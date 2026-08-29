#!/bin/bash
case "$1" in
  throttle)
    cpufreq-set -r -g powersave
    ;;
  restore)
    cpufreq-set -r -g performance
    ;;
  *)
    echo "Usage: $0 {throttle|restore}"
    exit 1
    ;;
esac
