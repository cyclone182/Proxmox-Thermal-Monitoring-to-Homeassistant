#!/bin/bash
# 1. CPU Temp in Fahrenheit
temp_raw=$(cat /sys/class/thermal/thermal_zone3/temp 2>/dev/null || echo 0)
cpu_temp_f=$(awk "BEGIN {print ($temp_raw/1000) * 1.8 + 32}")

# 2. NVMe SSD Temp in Fahrenheit
nvme_temp_c=$(sensors 2>/dev/null | grep "Composite:" | awk '{print $2}' | grep -o '[0-9.]*' || echo "0")
nvme_temp_f=$(awk "BEGIN {print ($nvme_temp_c * 1.8) + 32}")

# 3. CPU Frequency (Core 0, converted to MHz)
freq_raw=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq 2>/dev/null || echo 0)
cpu_freq=$(awk "BEGIN {print $freq_raw/1000}")

# 4. Active CPU Governor (performance or powersave)
pve_governor=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo "unknown")

# 5. Output formatted JSON string
printf '{"cpu_temp": %.1f, "nvme_temp": %.1f, "cpu_freq": %.0f, "pve_governor": "%s"}\n' "$cpu_temp_f" "$nvme_temp_f" "$cpu_freq" "$pve_governor"
