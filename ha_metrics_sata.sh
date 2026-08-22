#!/bin/bash

# 1. CPU Temp in Fahrenheit
temp_raw=$(cat /sys/class/thermal/thermal_zone3/temp 2>/dev/null || echo 0)
cpu_temp_f=$(awk "BEGIN {print ($temp_raw/1000) * 1.8 + 32}")

# 2. Drive Temp in Fahrenheit (using smartctl instead of sensors)
nvme_temp_c=$(smartctl -a /dev/sda 2>/dev/null | awk '/Temperature_Celsius/ {print $10}')
nvme_temp_c=${nvme_temp_c:-0}
nvme_temp_f=$(awk "BEGIN {print ($nvme_temp_c * 1.8) + 32}")

# 3. CPU Frequency (Core 0, pulled directly in MHz)
cpu_freq=$(grep "cpu MHz" /proc/cpuinfo | head -1 | awk '{print $4}')

# 4. Output as a formatted JSON string
printf '{"cpu_temp": %.1f, "nvme_temp": %.1f, "cpu_freq": %.0f}\n' "$cpu_temp_f" "$nvme_temp_f" "$cpu_freq"
